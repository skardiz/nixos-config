# hosts/shershulya/default.nix
# Этот файл теперь - чистейший декларативный манифест.
{ config, pkgs, lib, ... }:

{
  imports = [
    # Общая "Конституция" для всех машин
    ../_common/default.nix

    # Уникальная конфигурация железа для этого хоста
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia-pascal.nix
  ];

  # --- Уникальные настройки для хоста 'shershulya' ---

  networking.hostName = "shershulya";

  # Декларативное описание пользователей через наш кастомный API
  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      extraGroups = [ "adbusers" ];
    };
    mari = {
      description = "Mari";
    };
  };

  # Эта строка больше не нужна, так как 'inputs' передаются
  # глобально через specialArgs в flake.nix
  # home-manager.extraSpecialArgs = { inherit inputs; };
}
