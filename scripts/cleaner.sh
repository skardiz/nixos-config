#!/usr/bin/env bash
# cleaner.sh

# Включаем строгий режим
set -e

# --- Вспомогательные функции ---
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

# --- Этап 1: Удаление профилей поколений ---
msg "1. Удаление старых поколений системы (оставляем последние 10)..."
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
ok "Системные поколения очищены."

msg "2. Удаление старых поколений Home Manager для пользователя 'alex' (оставляем последние 10)..."
# --- КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: Указываем правильный путь к профилю Home Manager ---
# Путь к профилю Home Manager обычно: ~/.local/state/nix/profiles/home-manager
# Убедитесь, что пользователь, под которым запускается скрипт, имеет доступ к этому пути
nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --delete-generations +10
ok "Поколения Home Manager для 'alex' очищены."

# --- Этап 2: Сборка мусора ---
msg "3. Запуск сборщика мусора Nix (удаление осиротевших пакетов)..."
sudo nix-collect-garbage
ok "Сборка мусора Nix завершена."

# --- Этап 3: Оптимизация ---
msg "4. Оптимизация хранилища Nix (дедупликация)..."
sudo nix-store --optimise
ok "Оптимизация хранилища Nix завершена."

# --- Этап 4: Обслуживание Btrfs ---
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

# --- Этап 5: Очистка логов ---
msg "7. Очистка старых логов Journald (оставляем не более 500 МБ)..."
sudo journalctl --vacuum-size=500M
ok "Очистка логов Journald завершена."

ok "Все операции очистки и оптимизации завершены!"
