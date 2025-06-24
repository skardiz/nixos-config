#!/usr/bin/env bash
# Включаем строгий режим, но будем управлять им по ходу дела
set -eo pipefail

# --- Константы и вспомогательные функции для красоты ---
CONFIG_DIR="/home/alex/nixos-config"
LOG_FILE="/tmp/nixos-rebuild.log"

# Функции для цветного вывода
msg() { echo -e "\n\e[32m>>> $1\e[0m"; }
ok() { echo -e "\e[1;32m✅ $1\e[0m"; }
err() { echo -e "\n\e[1;31m❌ ОШИБКА: $1\e[0m"; }
warn() { echo -e "\n\e[1;33m⚠️ ВНИМАНИЕ: $1\e[0m"; }

# --- Шаг 0: Предварительные проверки ---
msg "Шаг 0: Предварительные проверки..."

# Проверка сети
if ! ping -c 1 -W 2 github.com &>/dev/null; then
  err "Нет подключения к интернету или github.com недоступен."
  exit 1
fi

# Проверка прав sudo
if ! sudo -v; then
    err "Не удалось получить права sudo. Проверьте пароль или настройки sudoers."
    exit 1
fi
ok "Сеть и права sudo в порядке."

# --- Основная логика ---
cd "$CONFIG_DIR" || exit

msg "Шаг 1: Обновление зависимостей (flake update)..."
if ! nix flake update; then
    err "Не удалось обновить flake. Проверьте подключение к сети и пути в flake.nix."
    exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
  warn "Нет изменений для коммита. Запускаем только быструю пересборку системы..."
  if ! sudo nixos-rebuild switch --flake .#shershulya; then
      err "Пересборка не удалась. Проверьте системные логи."
      exit 1
  fi
  ok "Система успешно пересобрана (без новых коммитов)!"
  exit 0
fi

if [ -z "$1" ]; then
  err "Есть изменения, но не указано сообщение для коммита.\nПример: rebuild \"feat: добавил новый пакет\""
  exit 1
fi

msg "Шаг 2: Добавление всех изменений в Git..."
git add -A

# --- Умная обработка ошибок сборки ---
set +e # Отключаем выход по ошибке, чтобы обработать ее вручную
msg "Шаг 3: Тестовая сборка системы (логи в $LOG_FILE)..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR" "$LOG_FILE"' EXIT # Убираем за собой и временную папку, и лог

(cd "$TMP_DIR" && sudo nixos-rebuild build --flake "$CONFIG_DIR#shershulya") &> "$LOG_FILE"
BUILD_SUCCESS=$? # Сохраняем код выхода последней команды
set -e # Возвращаем строгий режим

if [ $BUILD_SUCCESS -ne 0 ]; then
    err "Тестовая сборка НЕ УДАЛАСЬ."
    warn "Отменяем добавление файлов (git reset)..."
    git reset

    # Анализируем лог на известные проблемы
    if grep -q "hash mismatch" "$LOG_FILE" || grep -q "corrupted" "$LOG_FILE"; then
        warn "Обнаружена возможная проблема с поврежденным хранилищем Nix.\nПопробуйте запустить: sudo nix-store --verify --repair"
    elif grep -q "Could not resolve host" "$LOG_FILE"; then
        warn "Обнаружена сетевая ошибка во время сборки. Проверьте интернет-соединение."
    else
        warn "Подробности ошибки сохранены в файле: $LOG_FILE"
        tail -n 20 "$LOG_FILE"
    fi
    exit 1
fi
ok "Сборка прошла успешно!"

msg "Шаг 4: Создание коммита..."
git commit -m "$1"

msg "Шаг 5: Отправка изменений на GitHub..."
if ! git push; then
    err "Не удалось отправить изменения на GitHub. Проверьте сеть и права доступа к репозиторию."
    warn "Коммит был создан локально. Вы можете отправить его вручную позже."
    exit 1
fi

# --- Отдельная обработка ошибок активации ---
msg "Шаг 6: Активация новой конфигурации..."
set +e
sudo nixos-rebuild switch --flake .#shershulya &> "$LOG_FILE"
SWITCH_SUCCESS=$?
set -e

if [ $SWITCH_SUCCESS -ne 0 ]; then
    warn "АКТИВАЦИЯ НЕ УДАЛАСЬ, но сборка и коммит прошли успешно."
    warn "Ваша система все еще работает на предыдущем поколении."
    warn "Изучите лог ($LOG_FILE) для выявления проблемы (часто это ошибка в systemd-юните)."
    warn "Вы можете попробовать активировать это (уже собранное) поколение вручную позже."
    exit 1
fi

ok "Система успешно обновлена и изменения отправлены на GitHub!"
