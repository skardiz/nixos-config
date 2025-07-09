# hosts/shershulya/default.nix
{ inputs, self, mylib, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    # ../../modules/features/vpn.nix # Если нужно
  ];

  # Мы полностью убираем все, что связано с sops, из системной конфигурации.
  # Никаких sops.age.keyFile, sops.secrets, environment.etc, users.groups.sops.
  # Система больше не занимается секретами. Это задача Home Manager.

  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  # В extraGroups для пользователей больше не нужна группа 'sops'.
  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      extraGroups = [ "adbusers" ];
      home = {
        enableUserSshKey = true;
      };
    };
    mari = {
      description = "Mari";
      extraGroups = [];
      home = {
        enableUserSshKey = false;
      };
    };
  };
}
