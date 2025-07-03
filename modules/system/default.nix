# modules/system/default.nix
# Это центральный импорт для ВСЕХ хостов.
{ pkgs, inputs, ... }:

{
  imports = [
    # Фундаментальные настройки Nix
    ./nix.nix
    # Возможность использовать Sops
    ./sops.nix
    # Твои существующие core-модули
    ../../modules/core/options.nix
    ../../modules/core/users.nix
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
