#!/usr/bin/env bash
set -e

# --- Вспомогательные функции и переменные для сводки ---
msg() { echo -e "\n\e[32m>>> $1\e[0m"; }
ok() { echo -e "\e[1;32m✅ $1\e[0m"; }
warn() { echo -e "\n\e[1;33m⚠️ ВНИМАНИЕ: $1\e[0m"; }
err() { echo -e "\n\e[1;31m❌ ОШИБКА: $1\e[0m"; }

# Переменные для сбора результатов сводки
SUMMARY_NIX_GC_DELETED=""
SUMMARY_NIX_GC_FREED=""
SUMMARY_NIX_OPTIMISE_SAVED=""
SUMMARY_BTRFS_BALANCE=""
SUMMARY_BTRFS_SCRUB=""
SUMMARY_JOURNALD_FREED=""
SUMMARY_JOURNALD_SIZE=""

# --- Проверка прав sudo ---
if ! sudo -v; then
    err "Не удалось получить права sudo."
    exit 1
fi
ok "Права sudo получены."

# --- Этап 1: Удаление профилей поколений ---
# (Этот этап не генерирует сводку, так как его результат виден в сборке мусора)
msg "1. Удаление старых поколений системы и Home Manager (оставляем последние 10)..."
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --delete-generations +10 || true
ok "Профили поколений очищены."

# --- Этап 2: Сборка мусора ---
msg "2. Запуск сборщика мусора Nix..."
GC_OUTPUT=$(sudo nix-collect-garbage -v)
SUMMARY_NIX_GC_DELETED=$(echo "$GC_OUTPUT" | grep 'paths deleted' || echo "0 store paths deleted")
SUMMARY_NIX_GC_FREED=$(echo "$GC_OUTPUT" | grep 'MiB freed' || echo "0.00 MiB freed")
ok "Сборка мусора Nix завершена."

# --- Этап 3: Оптимизация ---
msg "3. Оптимизация хранилища Nix..."
# Захватываем вывод -vv, чтобы получить строку о hard linking
OPTIMISE_OUTPUT=$(sudo nix-store --optimise -vv 2>&1)
SUMMARY_NIX_OPTIMISE_SAVED=$(echo "$OPTIMISE_OUTPUT" | grep 'hard linking saves' || echo "no new hard linking savings found")
ok "Оптимизация хранилища Nix завершена."

# --- Этап 4: Обслуживание Btrfs ---
BTRFS_ROOT_MOUNTPOINT=$(findmnt -no TARGET -t btrfs / | head -n 1)
if [ -z "$BTRFS_ROOT_MOUNTPOINT" ]; then
    SUMMARY_BTRFS_BALANCE="Пропущено (не Btrfs)"
    SUMMARY_BTRFS_SCRUB="Пропущено (не Btrfs)"
    warn "Не удалось определить корневую точку монтирования Btrfs. Пропускаем обслуживание Btrfs."
else
    msg "4. Запуск балансировки Btrfs ($BTRFS_ROOT_MOUNTPOINT)..."
    warn "Это может быть очень длительная операция. Вы будете видеть прогресс."
    BALANCE_OUTPUT=$(sudo btrfs balance start -v --full-balance "$BTRFS_ROOT_MOUNTPOINT")
    SUMMARY_BTRFS_BALANCE=$(echo "$BALANCE_OUTPUT" | grep 'Done, had to relocate' || echo "Балансировка завершена.")
    ok "Балансировка Btrfs завершена."

    msg "5. Запуск проверки Btrfs (scrub)..."
    warn "Это может быть длительная операция. Скрипт будет ждать завершения."
    # Запускаем scrub в основном потоке и ждем его завершения
    sudo btrfs scrub start -B -d "$BTRFS_ROOT_MOUNTPOINT"
    # Получаем финальный статус после завершения
    SCRUB_STATUS=$(sudo btrfs scrub status "$BTRFS_ROOT_MOUNTPOINT" | grep 'scrub finished')
    SUMMARY_BTRFS_SCRUB=$(echo "$SCRUB_STATUS" | sed 's/^[ \t]*//') # Убираем лишние пробелы в начале
    ok "Проверка Btrfs (scrub) завершена."
fi

# --- Этап 5: Очистка логов ---
msg "6. Очистка старых логов Journald (оставляем не более 500 МБ)..."
VACUUM_OUTPUT=$(sudo journalctl --vacuum-size=500M)
# Извлекаем первую строку, где указано, сколько было освобождено
SUMMARY_JOURNALD_FREED=$(echo "$VACUUM_OUTPUT" | grep 'freed' | head -n 1)
SUMMARY_JOURNALD_SIZE=$(journalctl --disk-usage)
ok "Очистка логов Journald завершена."

# --- Финальная сводка ---
echo -e "\n\e[1;34m====================================\e[0m"
echo -e "\e[1;34m=== СВОДКА ОЧИСТКИ И ОПТИМИЗАЦИИ ===\e[0m"
echo -e "\e[1;34m====================================\e[0m"

echo -e "\e[1;36m1. Хранилище Nix:\e[0m"
echo -e "  - Сборка мусора: $SUMMARY_NIX_GC_DELETED, \e[1;32m$SUMMARY_NIX_GC_FREED\e[0m."
echo -e "  - Дедупликация: $SUMMARY_NIX_OPTIMISE_SAVED."

echo -e "\e[1;36m2. Файловая система Btrfs:\e[0m"
echo -e "  - Балансировка: $SUMMARY_BTRFS_BALANCE"
echo -e "  - Проверка (Scrub): $SUMMARY_BTRFS_SCRUB"

echo -e "\e[1;36m3. Системные логи:\e[0m"
echo -e "  - Очистка: \e[1;32m$SUMMARY_JOURNALD_FREED\e[0m."
echo -e "  - Финальный размер: $SUMMARY_JOURNALD_SIZE"

echo -e "\n\e[1;32m✅ Все операции завершены!\e[0m"
