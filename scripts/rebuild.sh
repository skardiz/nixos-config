#!/usr/bin/env bash
# Включаем строгий режим
set -eo pipefail

# --- Константы и вспомогательные функции ---
CONFIG_DIR="/home/alex/nixos-config"
LOG_FILE="/tmp/nixos-rebuild.log"
msg() { echo -e "\n\e[32m>>> $1\e[0m"; }
ok() { echo -e "\e[1;32m✅ $1\e[0m"; }
err() { echo -e "\n\e[1;31m❌ ОШИБКА: $1\e[0m"; }
warn() { echo -e "\n\e[1;33m⚠️ ВНИМАНИЕ: $1\e[0m"; }

# --- Шаг 0: Предварительные проверки ---
msg "Шаг 0: Предварительные проверки..."
if ! ping -c 1 -W 2 github.com &>/dev/null; then
  err "Нет подключения к интернету."
  exit 1
fi
if ! sudo -v; then
    err "Не удалось получить права sudo."
    exit 1
fi
ok "Сеть и права sudo в порядке."

# --- Основная логика ---
cd "$CONFIG_DIR" || exit

msg "Шаг 1: Обновление зависимостей..."
if ! nix flake update; then
    err "Не удалось обновить flake."
    exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
  warn "Нет изменений. Запускаем быструю пересборку..."
  sudo nixos-rebuild switch --flake .#shershulya
  ok "Система успешно пересобрана!"
  exit 0
fi

if [ -z "$1" ]; then
  err "Есть изменения, но нет сообщения для коммита.\nПример: rebuild \"feat: добавил nvidia-beta\""
  exit 1
fi

msg "Шаг 2: Добавление всех изменений в Git..."
git add -A

msg "Шаг 3: Тестовая сборка системы (вы видите живой прогресс)..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR" "$LOG_FILE"' EXIT

# --- КЛЮЧЕВОЕ ИЗМЕНЕНИЕ ---
# Выполняем сборку и направляем ее вывод одновременно в терминал и в лог-файл
set +o pipefail # Временно отключаем, чтобы получить код выхода именно от nixos-rebuild
(cd "$TMP_DIR" && sudo nixos-rebuild build --flake "$CONFIG_DIR#shershulya") 2>&1 | tee "$LOG_FILE"
BUILD_SUCCESS=${PIPESTATUS[0]} # Получаем код выхода первой команды в конвейере
set -o pipefail # Включаем обратно

if [ $BUILD_SUCCESS -ne 0 ]; then
    err "Тестовая сборка НЕ УДАЛАСЬ."
    warn "Отменяем добавление файлов (git reset)..."
    git reset
    warn "Подробности ошибки можно найти в файле: $LOG_FILE"
    tail -n 20 "$LOG_FILE"
    exit 1
fi
ok "Сборка прошла успешно!"

# ... (остальные шаги остаются без изменений) ...

msg "Шаг 4: Создание коммита..."
git commit -m "$1"

msg "Шаг 5: Отправка изменений на GitHub..."
if ! git push; then
    err "Не удалось отправить изменения на GitHub."
    warn "Коммит создан локально."
    exit 1
fi

msg "Шаг 6: Активация новой конфигурации..."
if ! sudo nixos-rebuild switch --flake .#shershulya; then
    err "АКТИВАЦИЯ НЕ УДАЛАСЬ, но сборка и коммит прошли успешно."
    warn "Система работает на предыдущем поколении. Изучите логи для выявления проблемы."
    exit 1
fi

ok "Система успешно обновлена и изменения отправлены на GitHub!"
