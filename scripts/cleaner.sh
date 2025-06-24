#!/usr/bin/env bash
# cleaner.sh

# Включаем строгий режим: скрипт завершится, если любая команда вернет ошибку.
set -e

# --- Вспомогательные функции для вывода сообщений ---
msg() { echo -e "\n\e[32m>>> $1\e[0m"; }
ok() { echo -e "\e[1;32m✅ $1\e[0m"; }
warn() { echo -e "\n\e[1;33m⚠️ ВНИМАНИЕ: $1\e[0m"; }
err() { echo -e "\n\e[1;31m❌ ОШИБКА: $1\e[0m"; }

# --- Проверка прав sudo ---
if ! sudo -v; then
    err "Не удалось получить права sudo."
    exit 1
fi
ok "Права sudo получены."

# --- ИСПРАВЛЕННЫЙ БЛОК: Удаление поколений по количеству ---
msg "1. Удаление старых поколений системы (оставляем последние 10)..."
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
ok "Системные поколения очищены."

msg "2. Удаление старых поколений Home Manager (оставляем последние 10)..."
# Запускается от вашего пользователя, без sudo
nix-env --profile /nix/var/nix/profiles/per-user/alex/profile --delete-generations +10
ok "Поколения Home Manager очищены."

# --- Основная сборка мусора ---
msg "3. Запуск сборщика мусора Nix (удаление осиротевших пакетов)..."
sudo nix-collect-garbage
ok "Сборка мусора Nix завершена."

# --- Оптимизация хранилища ---
msg "4. Оптимизация хранилища Nix (дедупликация)..."
sudo nix-store --optimise
ok "Оптимизация хранилища Nix завершена."

# --- Обслуживание Btrfs ---
BTRFS_ROOT_MOUNTPOINT=$(findmnt -no TARGET -t btrfs / | head -n 1)
if [ -z "$BTRFS_ROOT_MOUNTPOINT" ]; then
    warn "Не удалось определить корневую точку монтирования Btrfs. Пропускаем обслуживание Btrfs."
else
    msg "5. Запуск балансировки Btrfs ($BTRFS_ROOT_MOUNTPOINT)..."
    sudo btrfs balance start "$BTRFS_ROOT_MOUNTPOINT"
    ok "Балансировка Btrfs запущена в фоне."

    msg "6. Запуск проверки Btrfs (scrub)..."
    if ! sudo btrfs scrub status "$BTRFS_ROOT_MOUNTPOINT" | grep -q "scrub is running"; then
        sudo btrfs scrub start "$BTRFS_ROOT_MOUNTPOINT"
        ok "Btrfs scrub запущен в фоне."
    else
        warn "Btrfs scrub уже запущен. Пропускаем."
    fi
fi

msg "7. Очистка старых логов Journald до 500 МБ..."
sudo journalctl --vacuum-size=500M
ok "Очистка логов Journald завершена."

ok "Все операции очистки и оптимизации завершены!"
