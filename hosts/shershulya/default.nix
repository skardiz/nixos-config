# hosts/shershulya/default.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Общая "Конституция" для всех машин
    ../_common/default.nix

    # Уникальная конфигурация железа для этого хоста
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia-pascal.nix

    # Подключаем твики для Intel CPU только для этой машины
    ../../modules/hardware/intel-cpu.nix
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
}
