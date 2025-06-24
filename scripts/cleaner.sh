#!/usr/bin/env bash
set -e

# --- Цвета и вспомогательные функции ---
BLUE='\033[34m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

msg() { echo -e "\n${GREEN}>>> $1${RESET}"; } # Сообщения в процессе выполнения
ok() { echo -e "${GREEN}✅ $1${RESET}"; } # Подтверждение шага
warn() { echo -e "\n${YELLOW}⚠️ ВНИМАНИЕ: $1${RESET}"; }
err() { echo -e "\n${RED}❌ ОШИБКА: $1${RESET}"; }

# Переменные для сбора результатов сводки
SUMMARY_NIX_GEN_SYS=""
SUMMARY_NIX_GEN_HM=""
SUMMARY_NIX_GC=""
SUMMARY_NIX_OPTIMISE=""
SUMMARY_BTRFS_BALANCE=""
SUMMARY_BTRFS_SCRUB=""
SUMMARY_JOURNALD=""

# --- Проверка прав sudo ---
if ! sudo -v; then
    err "Не удалось получить права sudo."
    exit 1
fi
ok "Права sudo получены."

# --- Этап 1: Удаление профилей поколений ---
msg "1. Удаление старых поколений системы и Home Manager..."
old_gens_sys=$(sudo nix-env --profile /nix/var/nix/profiles/system --list-generations | wc -l)
old_gens_hm=$(nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --list-generations | wc -l || echo 0)

sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --delete-generations +10 || true

new_gens_sys=$(sudo nix-env --profile /nix/var/nix/profiles/system --list-generations | wc -l)
new_gens_hm=$(nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --list-generations | wc -l || echo 0)
deleted_gens_sys=$((old_gens_sys - new_gens_sys))
deleted_gens_hm=$((old_gens_hm - new_gens_hm))

SUMMARY_NIX_GEN_SYS="Система: удалено ${deleted_gens_sys} поколений, осталось ${new_gens_sys}."
SUMMARY_NIX_GEN_HM="Home Manager: удалено ${deleted_gens_hm} поколений, осталось ${new_gens_hm}."
ok "Очистка поколений завершена."

# --- Этап 2: Сборка мусора Nix ---
msg "2. Запуск сборщика мусора Nix..."
BEFORE_GC_SIZE=$(sudo du -sh /nix/store | cut -f1)
GC_OUTPUT=$(sudo nix-collect-garbage -v 2>&1)

DELETED_PATHS_COUNT=$(echo "$GC_OUTPUT" | grep 'paths deleted' | awk '{print $1}' || echo "0")
FREED_MB=$(echo "$GC_OUTPUT" | grep 'MiB freed' | awk '{print $1}' || echo "0.00")

AFTER_GC_SIZE=$(sudo du -sh /nix/store | cut -f1)

SUMMARY_NIX_GC="Удалено ${DELETED_PATHS_COUNT} путей, освобождено ${FREED_MB} MiB. Размер /nix/store: ${BEFORE_GC_SIZE} -> ${AFTER_GC_SIZE}."
ok "Сборка мусора Nix завершена."

# --- Этап 3: Оптимизация хранилища Nix ---
msg "3. Оптимизация хранилища Nix..."
OPTIMISE_OUTPUT=$(sudo nix-store --optimise -vv 2>&1)
# Ищем строку "note: currently hard linking saves X.XX MiB"
OPTIMISE_SAVED_LINE=$(echo "$OPTIMISE_OUTPUT" | grep 'hard linking saves' | sed -E 's/^.*(hard linking saves [0-9\.]+\s*(MiB|GiB)).*$/\1/' | head -n 1)

if [ -n "$OPTIMISE_SAVED_LINE" ]; then
    SUMMARY_NIX_OPTIMISE="${OPTIMISE_SAVED_LINE}."
else
    SUMMARY_NIX_OPTIMISE="Не обнаружено новых заметных сэкономленных мест."
fi
ok "Оптимизация хранилища Nix завершена."

# --- Этап 4: Обслуживание Btrfs ---
BTRFS_ROOT_MOUNTPOINT=$(findmnt -no TARGET -t btrfs / | head -n 1)
if [ -z "$BTRFS_ROOT_MOUNTPOINT" ]; then
    SUMMARY_BTRFS_BALANCE="Пропущено (не Btrfs)."
    SUMMARY_BTRFS_SCRUB="Пропущено (не Btrfs)."
    warn "Не удалось определить корневую точку монтирования Btrfs. Пропускаем."
else
    # Балансировка
    msg "4. Запуск балансировки Btrfs ($BTRFS_ROOT_MOUNTPOINT)..."
    warn "Это может быть очень длительная операция. Вы будете видеть прогресс."
    BALANCE_OUTPUT=$(sudo btrfs balance start -v --full-balance "$BTRFS_ROOT_MOUNTPOINT" 2>&1)

    # Парсим строку "Done, had to relocate X out of Y chunks"
    BALANCE_DONE_MSG=$(echo "$BALANCE_OUTPUT" | grep 'Done, had to relocate' | sed -E 's/^.*(Done, had to relocate .*)/\1/' | head -n 1)
    if [ -n "$BALANCE_DONE_MSG" ]; then
        SUMMARY_BTRFS_BALANCE="${BALANCE_DONE_MSG}."
    else
        SUMMARY_BTRFS_BALANCE="Балансировка завершена (без подробностей)."
    fi
    ok "Балансировка Btrfs завершена."

    # Scrub
    msg "5. Запуск проверки Btrfs (scrub) ($BTRFS_ROOT_MOUNTPOINT)..."
    warn "Это может быть очень длительная операция. Скрипт будет ждать завершения."
    sudo btrfs scrub start -B -d "$BTRFS_ROOT_MOUNTPOINT"
    SCRUB_STATUS_FULL=$(sudo btrfs scrub status "$BTRFS_ROOT_MOUNTPOINT")

    # Извлекаем данные, используя grep и sed с более надежными regex
    SCRUB_ERRORS=$(echo "$SCRUB_STATUS_FULL" | grep 'Error summary:' | sed -E 's/^[[:space:]]*Error summary:[[:space:]]*(.*)/\1/' | head -n 1)
    SCRUB_DURATION=$(echo "$SCRUB_STATUS_FULL" | grep 'Duration:' | sed -E 's/^[[:space:]]*Duration:[[:space:]]*(.*)/\1/' | head -n 1)

    SUMMARY_BTRFS_SCRUB="Ошибки: ${SCRUB_ERRORS}. Длительность: ${SCRUB_DURATION}."
    ok "Проверка Btrfs (scrub) завершена."
fi

# --- Этап 5: Очистка логов Journald ---
msg "6. Очистка старых логов Journald..."
# Получаем размер до очистки
BEFORE_JOURNAL_SIZE_FULL=$(journalctl --disk-usage)
BEFORE_JOURNAL_SIZE=$(echo "$BEFORE_JOURNAL_SIZE_FULL" | awk '{print $NF}') # Последнее поле (например, "1.2G")

VACUUM_OUTPUT=$(sudo journalctl --vacuum-size=500M 2>&1)

# Парсим освобожденное место
FREED_JOURNAL_AMOUNT=$(echo "$VACUUM_OUTPUT" | grep 'freed' | head -n 1 | sed -E 's/.*freed ([0-9\.]+[KMGT]?B).* from.*/\1/') # Извлекаем только число и единицы
if [ -z "$FREED_JOURNAL_AMOUNT" ]; then # Если ничего не освободилось, строка будет пустой
    FREED_JOURNAL_AMOUNT="0B"
fi

# Получаем финальный размер логов (запрашиваем заново, чтобы быть уверенным)
AFTER_JOURNAL_SIZE_FULL=$(journalctl --disk-usage)
AFTER_JOURNAL_SIZE=$(echo "$AFTER_JOURNAL_SIZE_FULL" | awk '{print $NF}') # Последнее поле

SUMMARY_JOURNALD="Освобождено ${FREED_JOURNAL_AMOUNT}. Текущий размер: ${AFTER_JOURNAL_SIZE}."
ok "Очистка логов Journald завершена."

# --- Финальная сводка ---
echo -e "\n${BLUE}====================================${RESET}"
echo -e "${BLUE}=== СВОДКА ОЧИСТКИ И ОПТИМИЗАЦИИ ===${RESET}"
echo -e "${BLUE}====================================\n${RESET}"

echo -e "${CYAN}1. Поколения Nix:${RESET}"
printf "  - Система: %s\n" "$SUMMARY_NIX_GEN_SYS"
printf "  - Home Manager: %s\n" "$SUMMARY_NIX_GEN_HM"

echo -e "\n${CYAN}2. Хранилище Nix:${RESET}"
printf "  - Сборка мусора: %s\n" "$SUMMARY_NIX_GC"
printf "  - Оптимизация: %s\n" "$SUMMARY_NIX_OPTIMISE"

echo -e "\n${CYAN}3. Файловая система Btrfs:${RESET}"
printf "  - Балансировка: %s\n" "$SUMMARY_BTRFS_BALANCE"
printf "  - Scrub: %s\n" "$SUMMARY_BTRFS_SCRUB"

echo -e "\n${CYAN}4. Системные логи:${RESET}"
printf "  - %s\n" "$SUMMARY_JOURNALD"

echo -e "\n${GREEN}✅ Все операции завершены!${RESET}"
