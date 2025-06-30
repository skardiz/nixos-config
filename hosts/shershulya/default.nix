# hosts/shershulya/default.nix
#
# Этот файл отвечает ТОЛЬКО за то, что уникально для машины 'shershulya'.
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Общая "Конституция" для всех машин
    ../_common/default.nix

    # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
    # Явно импортируем профиль десктопа, так как эта машина - десктоп.
    ../../modules/roles/desktop.nix

    # Уникальная конфигурация железа для этого хоста
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  # --- Уникальные настройки для хоста 'shershulya' ---

  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

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
