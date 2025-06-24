#!/usr/bin/env bash
set -e

# --- Цвета и вспомогательные функции ---
BLUE='\033[34m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

msg() { echo -e "\n${GREEN}>>> $1${RESET}"; }
ok() { echo -e "${GREEN}✅ $1${RESET}"; }
warn() { echo -e "\n${YELLOW}⚠️ ВНИМАНИЕ: $1${RESET}"; }
err() { echo -e "\n${RED}❌ ОШИБКА: $1${RESET}"; }

# --- Переменные для сбора результатов сводки ---
SUMMARY_NIX_GEN_SYS=""
SUMMARY_NIX_GEN_HM=""
SUMMARY_NIX_GC=""
SUMMARY_NIX_OPTIMISE=""
SUMMARY_JOURNALD=""
# Переменные Btrfs инициализируются как "пропущенные" по умолчанию
SUMMARY_BTRFS_BALANCE="Пропущено."
SUMMARY_BTRFS_SCRUB="Пропущено."
BTRFS_OPERATIONS_PERFORMED=false # Флаг для контроля вывода сводки

# Файл для временного хранения вывода balance
BALANCE_LOG_FILE="/tmp/btrfs_balance.log"
trap 'rm -f "$BALANCE_LOG_FILE"' EXIT # Гарантируем удаление лога при выходе

# --- Проверка прав sudo ---
if ! sudo -v; then
    err "Не удалось получить права sudo."
    exit 1
fi
ok "Права sudo получены."

# --- ОБЯЗАТЕЛЬНЫЕ ЭТАПЫ ---

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
SUMMARY_NIX_GEN_SYS="Удалено ${deleted_gens_sys} системных поколений, осталось ${new_gens_sys}."
SUMMARY_NIX_GEN_HM="Удалено ${deleted_gens_hm} поколений Home Manager, осталось ${new_gens_hm}."
ok "Очистка поколений завершена."

# --- Этап 2: Сборка мусора Nix ---
msg "2. Запуск сборщика мусора Nix..."
BEFORE_GC_SIZE_MB=$(sudo du -sBM /nix/store | sed 's/M$//')
GC_OUTPUT=$(sudo nix-collect-garbage -v 2>&1)
DELETED_PATHS_COUNT=$(echo "$GC_OUTPUT" | grep 'paths deleted' | awk '{print $1}' || echo "0")
FREED_MB=$(echo "$GC_OUTPUT" | grep 'MiB freed' | awk '{print $1}' || echo "0.00")
AFTER_GC_SIZE_MB=$(sudo du -sBM /nix/store | sed 's/M$//')
SUMMARY_NIX_GC="Удалено ${DELETED_PATHS_COUNT} путей, освобождено ${FREED_MB} MiB. Размер /nix/store: ${BEFORE_GC_SIZE_MB} MB -> ${AFTER_GC_SIZE_MB} MB."
ok "Сборка мусора Nix завершена."

# --- Этап 3: Оптимизация хранилища Nix ---
msg "3. Оптимизация хранилища Nix..."
OPTIMISE_OUTPUT=$(sudo nix-store --optimise -vv 2>&1)
OPTIMISE_SAVED_LINE=$(echo "$OPTIMISE_OUTPUT" | grep -oP 'hard linking saves \d+\.?\d*\s*(MiB|GiB)' | head -n 1)
if [ -n "$OPTIMISE_SAVED_LINE" ]; then
    SAVED_AMOUNT=$(echo "$OPTIMISE_SAVED_LINE" | sed -E 's/hard linking saves //')
    SUMMARY_NIX_OPTIMISE="Экономия за счет дедупликации: ${SAVED_AMOUNT}."
else
    SUMMARY_NIX_OPTIMISE="Не обнаружено новых заметных сэкономленных мест."
fi
ok "Оптимизация хранилища Nix завершена."

# --- ИНТЕРАКТИВНЫЙ ВЫБОР ДЛЯ BTRFS ---
BTRFS_ROOT_MOUNTPOINT=$(findmnt -no TARGET -t btrfs / | head -n 1)
if [ -n "$BTRFS_ROOT_MOUNTPOINT" ]; then
    echo # Пустая строка для отступа
    read -r -p "Вы хотите выполнить обслуживание Btrfs (balance и scrub)? Это может занять много времени. (y/n) " user_choice
    echo # Пустая строка для отступа

    # Приводим ответ к нижнему регистру для удобства сравнения
    user_choice_lower=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$user_choice_lower" == "y" || "$user_choice_lower" == "yes" || "$user_choice_lower" == "д" || "$user_choice_lower" == "да" ]]; then
        BTRFS_OPERATIONS_PERFORMED=true

        # Балансировка
        msg "4. Запуск балансировки Btrfs ($BTRFS_ROOT_MOUNTPOINT)..."
        warn "Это может быть очень длительная операция. Вы будете видеть прогресс."
        sudo btrfs balance start -v --full-balance "$BTRFS_ROOT_MOUNTPOINT" | tee "$BALANCE_LOG_FILE" > /dev/null
        BALANCE_DONE_MSG=$(grep 'Done, had to relocate' "$BALANCE_LOG_FILE" | sed -E 's/^[[:space:]]*(.*)/\1/' | head -n 1)
        SUMMARY_BTRFS_BALANCE="Балансировка: ${BALANCE_DONE_MSG:-Завершено без подробностей}."
        ok "Балансировка Btrfs завершена."

        # Scrub
        msg "5. Запуск проверки Btrfs (scrub) ($BTRFS_ROOT_MOUNTPOINT)..."
        warn "Это может быть длительная операция. Скрипт будет ждать завершения."
        sudo btrfs scrub start -B -d "$BTRFS_ROOT_MOUNTPOINT"
        SCRUB_STATUS_FULL=$(sudo btrfs scrub status "$BTRFS_ROOT_MOUNTPOINT")
        SCRUB_ERRORS_RAW=$(echo "$SCRUB_STATUS_FULL" | grep 'Error summary:' | sed -E 's/^[[:space:]]*Error summary:[[:space:]]*(.*)/\1/')
        SCRUB_ERRORS=$(echo "$SCRUB_ERRORS_RAW" | sed 's/no errors found/не найдено/')
        SCRUB_DURATION=$(echo "$SCRUB_STATUS_FULL" | grep 'Duration:' | sed -E 's/^[[:space:]]*Duration:[[:space:]]*(.*)/\1/')
        SUMMARY_BTRFS_SCRUB="Scrub: Ошибки: ${SCRUB_ERRORS}. Длительность: ${SCRUB_DURATION}."
        ok "Проверка Btrfs (scrub) завершена."
    else
        SUMMARY_BTRFS_BALANCE="Пропущено по выбору пользователя."
        SUMMARY_BTRFS_SCRUB="Пропущено по выбору пользователя."
        warn "Обслуживание Btrfs пропущено."
    fi
else
    SUMMARY_BTRFS_BALANCE="Пропущено (файловая система не Btrfs)."
    SUMMARY_BTRFS_SCRUB="Пропущено (файловая система не Btrfs)."
fi

# --- ЗАВЕРШАЮЩИЙ ОБЯЗАТЕЛЬНЫЙ ЭТАП ---
msg "6. Очистка старых логов Journald..."
BEFORE_JOURNAL_SIZE=$(journalctl --disk-usage | grep -oP '\d+\.?\d*[KMGT]?B' | head -n 1)
VACUUM_OUTPUT=$(sudo journalctl --vacuum-size=500M 2>&1)
FREED_JOURNAL_AMOUNT=$(echo "$VACUUM_OUTPUT" | grep -oP 'freed \d+\.?\d*[KMGT]?B' | head -n 1 | sed 's/freed //')
AFTER_JOURNAL_SIZE=$(journalctl --disk-usage | grep -oP '\d+\.?\d*[KMGT]?B' | head -n 1)
SUMMARY_JOURNALD="Освобождено ${FREED_JOURNAL_AMOUNT:-0B}. Текущий размер: ${AFTER_JOURNAL_SIZE}."
ok "Очистка логов Journald завершена."

# --- ФИНАЛЬНАЯ СВОДКА ---
echo -e "\n${BLUE}====================================${RESET}"
echo -e "${BLUE}=== СВОДКА ОЧИСТКИ И ОПТИМИЗАЦИИ ===${RESET}"
echo -e "${BLUE}====================================\n${RESET}"

printf "${CYAN}%-25s%s${RESET}\n" "1. Поколения Nix:" ""
printf "  - Системные: %s\n" "$SUMMARY_NIX_GEN_SYS"
printf "  - Home Manager: %s\n" "$SUMMARY_NIX_GEN_HM"

printf "\n${CYAN}%-25s%s${RESET}\n" "2. Хранилище Nix:" ""
printf "  - Сборка мусора: %s\n" "$SUMMARY_NIX_GC"
printf "  - Оптимизация: %s\n" "$SUMMARY_NIX_OPTIMISE"

# Выводим блок Btrfs только если он был выполнен
if [ "$BTRFS_OPERATIONS_PERFORMED" = true ]; then
    printf "\n${CYAN}%-25s%s${RESET}\n" "3. Файловая система Btrfs:" ""
    printf "  - Балансировка: %s\n" "$SUMMARY_BTRFS_BALANCE"
    printf "  - Scrub: %s\n" "$SUMMARY_BTRFS_SCRUB"
fi

printf "\n${CYAN}%-25s%s${RESET}\n" "4. Системные логи Journald:" ""
printf "  - %s\n" "$SUMMARY_JOURNALD"

echo -e "\n${GREEN}✅ Все операции завершены!${RESET}"
