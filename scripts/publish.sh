#!/bin/bash

# --- Безопасность и надежность ---
set -e

# --- Конфигурация ---
REPO_DIR="/home/alex/nixos-config"

# --- Логика скрипта ---
echo "🚀 Начинаем публикацию конфигурации..."

cd "$REPO_DIR" || { echo "❌ Ошибка: Не удалось найти папку $REPO_DIR"; exit 1; }

if [ -z "$(git status --porcelain)" ]; then
  echo "✅ Нет изменений для публикации. Все уже синхронизировано."
  exit 0
fi

echo "🔄 Добавляем все файлы в отслеживание..."
git add --all

read -p "💬 Введите краткое описание изменений (например, 'добавил новый пакет'): " COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
  echo "❌ Ошибка: Сообщение коммита не может быть пустым."
  exit 1
fi

echo "📝 Создаем коммит..."
git commit -m "$COMMIT_MSG"

echo "☁️ Отправляем изменения на GitHub..."
git push

echo "🎉 Готово! Ваши изменения успешно опубликованы на GitHub."
