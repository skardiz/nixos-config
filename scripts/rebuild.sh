#!/usr/bin/env bash
set -e
cd /home/alex/nixos-config
if git diff-index --quiet HEAD --; then
  echo -e "\n\e[33m>>> Нет изменений для коммита. Запускаем только сборку системы...\e[0m"
  sudo nixos-rebuild switch --flake .#shershulya
  echo -e "\n\e[1;32m✅ Система успешно пересобрана (без новых коммитов)!\e[0m"
  exit 0
fi
if [ -z "$1" ]; then
  echo "Ошибка: есть изменения, но не указано сообщение для коммита."
  echo "Пример: rebuild \"feat: добавил новый пакет\""
  exit 1
fi
echo -e "\n\e[32m>>> Шаг 1: Добавление изменений в Git...\e[0m"
git add .
echo -e "\n\e[32m>>> Шаг 2: Создание коммита...\e[0m"
git commit -m "$1"
echo -e "\n\e[32m>>> Шаг 3: Запуск сборки системы NixOS...\e[0m"
sudo nixos-rebuild switch --flake .#shershulya
echo -e "\n\e[32m>>> Шаг 4: Отправка изменений на GitHub...\e[0m"
git push
echo -e "\n\e[1;32m✅ Система успешно обновлена и изменения отправлены на GitHub!\e[0m"
