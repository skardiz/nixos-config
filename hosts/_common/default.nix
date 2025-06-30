# hosts/_common/default.nix
#
# "Конституция" для всех моих систем.
{ pkgs, ... }:

{
  imports = [
    # Подключаем наш "пульт управления"
    ../../modules/options.nix
    # Подключаем модуль для кастомных пакетов
    ../../modules/packages.nix
    # Подключаем наш API для пользователей
    ../../modules/users.nix
    # Подключаем наш стандартный профиль десктопа
    ../../modules/profiles/desktop.nix
  ];

  # --- Глобальные политики и сервисы ---
  # Декларативно включаем все, что нам нужно, через наш собственный API
  my = {
    # Включаем наши глобальные политики
    policies = {
      allowUnfree = true;
      enableAutoGc = true;
      enableFlakes = true;
    };

    # Включаем наш "Базовый Пакет Коммунальных Услуг"
    services.enableCore = true;
  };
}
