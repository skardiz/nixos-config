# hosts/_common/default.nix
{
  imports = [
    # Сначала импортируем наш "пульт управления"
    ../../modules/options.nix

    # Затем импортируем наш новый модуль для пакетов
    ../../modules/packages.nix

    # Затем наш новый модуль для пользователей
    ../../modules/users.nix

    # Затем импортируем наш стандартный профиль десктопа
    ../../modules/profiles/desktop.nix
  ];

  # Фундаментальные настройки системы
  system.stateVersion = "25.11";

  # Глобальные политики
  my.policies = {
    allowUnfree = true;
    enableAutoGc = true;
    enableFlakes = true;
  };
}
