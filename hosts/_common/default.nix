# hosts/_common/default.nix
#
# "Конституция" для всех моих систем.
{ pkgs, ... }:

{
  imports = [
    # Подключаем наш "пульт управления"
    ../../modules/core/options.nix
    # Подключаем наш API для пользователей
    ../../modules/core/users.nix

    # Эта строка переезжает в файл конкретного хоста,
    # так как не все машины будут десктопами.
    # ../../modules/profiles/desktop.nix
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
