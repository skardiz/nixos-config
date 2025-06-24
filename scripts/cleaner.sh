#!/usr/bin/env bash
set -e

# --- Вспомогательные функции и переменные для сводки ---
msg() { echo -e "\n\e[32m>>> $1\e[0m"; }
ok() { echo -e "\e[1;32m✅ $1\e[0m"; }
warn() { echo -e "\n\e[1;33m⚠️ ВНИМАНИЕ: $1\e[0m"; }
err() { echo -e "\n\e[1;31m❌ ОШИБКА: $1\e[0m"; }

# Переменные для сбора результатов сводки
SUMMARY_NIX_GC=""
SUMMARY_HM_GC=""
SUMMARY_NIX_STORE_OPTIMISE=""
SUMMARY_BTRFS_BALANCE=""
SUMMARY_BTRFS_SCRUB=""
SUMMARY_JOURNALD_GC=""

# --- Проверка прав sudo ---
if ! sudo -v; then
    err "Не удалось получить права sudo."
    exit 1
fi
ok "Права sudo получены."

# --- Этап 1: Удаление профилей поколений ---
msg "1. Удаление старых поколений системы (оставляем последние 10)..."
old_gens_sys=$(sudo nix-env --profile /nix/var/nix/profiles/system --list-generations | wc -l)
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
new_gens_sys=$(sudo nix-env --profile /nix/var/nix/profiles/system --list-generations | wc -l)
deleted_gens_sys=$((old_gens_sys - new_gens_sys))
SUMMARY_NIX_GC="Системные поколения: удалено $deleted_gens_sys."
ok "Системные поколения очищены."

msg "2. Удаление старых поколений Home Manager для пользователя 'alex' (оставляем последние 10)..."
old_gens_hm=$(nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --list-generations | wc -l || echo 0)
nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --delete-generations +10 || true
new_gens_hm=$(nix-env --profile "$HOME/.local/state/nix/profiles/home-manager" --list-generations | wc -l || echo 0)
deleted_gens_hm=$((old_gens_hm - new_gens_hm))
SUMMARY_HM_GC="Поколения Home Manager: удалено $deleted_gens_hm."
ok "Поколения Home Manager очищены."

# --- Этап 2: Сборка мусора ---
msg "3. Запуск сборщика мусора Nix (удаление осиротевших пакетов)..."
before_gc=$(du -sh /nix/store | cut -f1)
sudo nix-collect-garbage
after_gc=$(du -sh /nix/store | cut -f1)
SUMMARY_NIX_STORE_OPTIMISE="Размер /nix/store: $before_gc -> $after_gc."
ok "Сборка мусора Nix завершена."

# --- Этап 3: Оптимизация ---
msg "4. Оптимизация хранилища Nix (дедупликация)..."
# Вывод optimisation сохраняем в переменную
optimise_output=$(sudo nix-store --optimise -vv 2>&1)
# Ищем строки, указывающие на экономию места
savings=$(echo "$optimise_output" | grep -E "saving|hard linking" || echo "Нет заметных оптимизаций.")
SUMMARY_NIX_STORE_OPTIMISE+="\n  Оптимизация: $savings" # Добавляем к предыдущей сводке
ok "Оптимизация хранилища Nix завершена."

# --- Этап 4: Обслуживание Btrfs ---
BTRFS_ROOT_MOUNTPOINT=$(findmnt -no TARGET -t btrfs / | head -n 1)
if [ -z "$BTRFS_ROOT_MOUNTPOINT" ]; then
    SUMMARY_BTRFS_BALANCE="Балансировка Btrfs: пропущена (не Btrfs)."
    SUMMARY_BTRFS_SCRUB="Scrub Btrfs: пропущен (не Btrfs)."
    warn "Не удалось определить корневую точку монтирования Btrfs. Пропускаем обслуживание Btrfs."
else
    msg "5. Запуск балансировки Btrfs ($BTRFS_ROOT_MOUNTPOINT)..."
    warn "Это может быть очень длительная операция. Вы будете видеть прогресс обработки чанков."
    # Запускаем balance в основном потоке с опцией -v для вывода прогресса
    if sudo btrfs balance start -v --full-balance "$BTRFS_ROOT_MOUNTPOINT"; then
        SUMMARY_BTRFS_BALANCE="Балансировка Btrfs: завершена успешно."
        ok "Балансировка Btrfs завершена."
    else
        SUMMARY_BTRFS_BALANCE="Балансировка Btrfs: завершилась с ошибкой."
        err "Балансировка Btrfs завершилась с ошибкой."
    fi

    msg "6. Запуск проверки Btrfs (scrub)..."
    if ! sudo btrfs scrub status "$BTRFS_ROOT_MOUNTPOINT" | grep -q "scrub is running"; then
        sudo btrfs scrub start "$BTRFS_ROOT_MOUNTPOINT"
        SUMMARY_BTRFS_SCRUB="Scrub Btrfs: запущен в фоне."
        ok "Scrub запущен в фоне."
    else
        SUMMARY_BTRFS_SCRUB="Scrub Btrfs: уже запущен."
        warn "Scrub уже запущен. Пропускаем."
    fi
fi

# --- Этап 5: Очистка логов ---
msg "7. Очистка старых логов Journald (оставляем не более 500 МБ)..."
before_journal=$(journalctl --disk-usage | awk '{print $NF}') # Получаем только число размера
sudo journalctl --vacuum-size=500M
after_journal=$(journalctl --disk-usage | awk '{print $NF}')
SUMMARY_JOURNALD_GC="Journald логи: $before_journal -> $after_journal."
ok "Очистка логов Journald завершена."

# --- Финальная сводка ---
echo -e "\n\e[1;34m====================================\e[0m"
echo -e "\e[1;34m=== СВОДКА ОЧИСТКИ И ОПТИМИЗАЦИИ ===\e[0m"
echo -e "\e[1;34m====================================\e[0m"

echo -e "\e[1;36m1. Очистка поколений Nix:\e[0m"
echo -e "  - $SUMMARY_NIX_GC"
echo -e "  - $SUMMARY_HM_GC"

echo -e "\e[1;36m2. Очистка хранилища Nix:\e[0m"
echo -e "  - $SUMMARY_NIX_STORE_OPTIMISE"

echo -e "\e[1;36m3. Обслуживание Btrfs:\e[0m"
echo -e "  - $SUMMARY_BTRFS_BALANCE"
echo -e "  - $SUMMARY_BTRFS_SCRUB"

echo -e "\e[1;36m4. Очистка логов Journald:\e[0m"
echo -e "  - $SUMMARY_JOURNALD_GC"

echo -e "\n\e[1;32m✅ Все операции завершены!\e[0m"
