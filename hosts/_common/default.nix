# hosts/_common/default.nix
#
# "Конституция" для всех моих систем.
{
  imports = [
    # Сначала импортируем наш "пульт управления"
    ../../modules/options.nix

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
