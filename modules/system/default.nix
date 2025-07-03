# modules/system/default.nix
#
# Это центральный "хаб" для ВСЕХ системных настроек.
# Фундамент для любого хоста в нашей конфигурации.
{ pkgs, inputs, ... }:

{
  imports = [
    # Фундаментальные настройки Nix
    ./nix.nix

    # Возможность использовать Sops
    ./sops.nix

    # Наши собственные базовые опции (бывший core/options.nix)
    ./options.nix

    # Наш API для управления пользователями (бывший core/users.nix)
    ./users.nix
  ];

  # Твои глобальные политики
  my = {
    policies = {
      allowUnfree = true;
      enableAutoGc = true;
      enableFlakes = true;
    };
    services.enableCore = true;
  };
}
