#!/usr/bin/env bash
set -e

# --- Вспомогательные функции и переменные для сводки ---
msg() { echo -e "\n\e[32m>>> $1\e[0m"; }
ok() { echo -e "\e[1;32m✅ $1\e[0m"; }
warn() { echo -e "\n\e[1;33m⚠️ ВНИМАНИЕ: $1\e[0m"; }
err() { echo -e "\n\e[1;31m❌ ОШИБКА: $1\e[0m"; }

# Переменные для сбора результатов сводки
SUMMARY_NIX_GEN_SYS="Не выполнено."
SUMMARY_NIX_GEN_HM="Не выполнено."
SUMMARY_NIX_GC="Не выполнено."
SUMMARY_NIX_OPTIMISE="Не выполнено."
SUMMARY_BTRFS_BALANCE="Не выполнено."
SUMMARY_BTRFS_SCRUB="Не выполнено."
SUMMARY_JOURNALD="Не выполнено."

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
SUMMARY_NIX_GEN_SYS="Системные поколения: удалено $deleted_gens_sys. Осталось $new_gens_sys."
SUMMARY_NIX_GEN_HM="Home Manager поколения: удалено $deleted_gens_hm. Осталось $new_gens_hm."
ok "Очистка поколений завершена."

# --- Этап 2: Сборка мусора Nix ---
msg "2. Запуск сборщика мусора Nix..."
BEFORE_GC_SIZE=$(sudo du -sh /nix/store | cut -f1)
GC_OUTPUT=$(sudo nix-collect-garbage -v 2>&1)
DELETED_PATHS=$(echo "$GC_OUTPUT" | grep 'paths deleted' | awk '{print $1}' || echo "0")
FREED_MIB=$(echo "$GC_OUTPUT" | grep 'MiB freed' | awk '{print $1}' || echo "0.00")
AFTER_GC_SIZE=$(sudo du -sh /nix/store | cut -f1)
SUMMARY_NIX_GC="Удалено $DELETED_PATHS пути(ей), освобождено ${FREED_MIB} MiB. Размер: $BEFORE_GC_SIZE -> $AFTER_GC_SIZE."
ok "Сборка мусора Nix завершена."

# --- Этап 3: Оптимизация хранилища Nix ---
msg "3. Оптимизация хранилища Nix..."
OPTIMISE_OUTPUT=$(sudo nix-store --optimise -vv 2>&1)
OPTIMISE_SAVED_LINE=$(echo "$OPTIMISE_OUTPUT" | grep 'hard linking saves' || echo "") # Извлекаем всю строку
if [ -n "$OPTIMISE_SAVED_LINE" ]; then # Если строка не пустая
    SUMMARY_NIX_OPTIMISE="Оптимизация: $(echo "$OPTIMISE_SAVED_LINE" | sed 's/^[ \t]*//')."
else
    SUMMARY_NIX_OPTIMISE="Оптимизация: Нет новых заметных оптимизаций." # Если строка пустая
fi
ok "Оптимизация хранилища Nix завершена."

# --- Этап 4: Обслуживание Btrfs ---
BTRFS_ROOT_MOUNTPOINT=$(findmnt -no TARGET -t btrfs / | head -n 1)
if [ -z "$BTRFS_ROOT_MOUNTPOINT" ]; then
    SUMMARY_BTRFS_BALANCE="Пропущено (не Btrfs)."
    SUMMARY_BTRFS_SCRUB="Пропущено (не Btrfs)."
    warn "Не удалось определить корневую точку монтирования Btrfs. Пропускаем."
else
    msg "4. Запуск балансировки Btrfs ($BTRFS_ROOT_MOUNTPOINT)..."
    warn "Это может быть очень длительная операция. Вы будете видеть прогресс."
    BALANCE_OUTPUT=$(sudo btrfs balance start -v --full-balance "$BTRFS_ROOT_MOUNTPOINT" 2>&1)
    BALANCE_DONE_MSG=$(echo "$BALANCE_OUTPUT" | grep 'Done, had to relocate' || echo "Балансировка завершена (без подробностей).")
    SUMMARY_BTRFS_BALANCE="Балансировка: $(echo "$BALANCE_DONE_MSG" | sed 's/^[ \t]*//')."
    ok "Балансировка Btrfs завершена."

    msg "5. Запуск проверки Btrfs (scrub) ($BTRFS_ROOT_MOUNTPOINT)..."
    warn "Это может быть длительная операция. Скрипт будет ждать завершения."
    sudo btrfs scrub start -B -d "$BTRFS_ROOT_MOUNTPOINT"
    SCRUB_STATUS_FULL=$(sudo btrfs scrub status "$BTRFS_ROOT_MOUNTPOINT")
    SCRUB_SUMMARY_LINE=$(echo "$SCRUB_STATUS_FULL" | grep 'Error summary' | sed 's/^[ \t]*//')
    SCRUB_DURATION_LINE=$(echo "$SCRUB_STATUS_FULL" | grep 'Duration' | sed 's/^[ \t]*//')
    SUMMARY_BTRFS_SCRUB="Scrub: $SCRUB_SUMMARY_LINE. $SCRUB_DURATION_LINE."
    ok "Проверка Btrfs (scrub) завершена."
fi

# --- Этап 5: Очистка логов Journald ---
msg "6. Очистка старых логов Journald (оставляем не более 500 МБ)..."

# Получаем размер до очистки
# Извлекаем размер из "Journals take up 123.4M on disk."
BEFORE_JOURNAL_SIZE_FULL=$(journalctl --disk-usage)
BEFORE_JOURNAL_SIZE=$(echo "$BEFORE_JOURNAL_SIZE_FULL" | awk '{print $NF}')

VACUUM_OUTPUT=$(sudo journalctl --vacuum-size=500M 2>&1)

# Проверяем, было ли что-то удалено (строка "freed" в выводе)
FREED_JOURNAL_LINE=$(echo "$VACUUM_OUTPUT" | grep 'freed' | head -n 1 || echo "")
if [ -n "$FREED_JOURNAL_LINE" ]; then
    # Извлекаем только размер освобожденного
    FREED_JOURNAL=$(echo "$FREED_JOURNAL_LINE" | awk '{print $3 $4}')
    VACUUM_MSG="Освобождено $FREED_JOURNAL."
else
    VACUUM_MSG="Ничего не освобождено (логи уже в пределах лимита)."
fi

# Получаем размер после очистки
AFTER_JOURNAL_SIZE_FULL=$(journalctl --disk-usage)
AFTER_JOURNAL_SIZE=$(echo "$AFTER_JOURNAL_SIZE_FULL" | awk '{print $NF}')

SUMMARY_JOURNALD="Логи: $VACUUM_MSG Текущий размер: $AFTER_JOURNAL_SIZE."
ok "Очистка логов Journald завершена."

# --- Финальная сводка ---
echo -e "\n\e[1;34m====================================\e[0m"
echo -e "\e[1;34m=== СВОДКА ОЧИСТКИ И ОПТИМИЗАЦИИ ===\e[0m"
echo -e "\e[1;34m====================================\e[0m"

echo -e "\n\e[1;36m1. Поколения Nix:\e[0m"
echo -e "  - $SUMMARY_NIX_GEN_SYS"
echo -e "  - $SUMMARY_NIX_GEN_HM"

echo -e "\n\e[1;36m2. Хранилище Nix:\e[0m"
echo -e "  - $SUMMARY_NIX_GC"
echo -e "  - $SUMMARY_NIX_OPTIMISE"

echo -e "\n\e[1;36m3. Файловая система Btrfs:\e[0m"
echo -e "  - $SUMMARY_BTRFS_BALANCE"
echo -e "  - $SUMMARY_BTRFS_SCRUB"

echo -e "\n\e[1;36m4. Системные логи:\e[0m"
echo -e "  - $SUMMARY_JOURNALD"

echo -e "\n\e[1;32m✅ Все операции завершены!\e[0m"
