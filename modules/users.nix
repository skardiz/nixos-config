{ pkgs, ... }:
{
  # Создаем группу для управления конфигурацией
  users.groups.nixos-config = {};

  users.users = {
    alex = {
      isNormalUser = true;
      extraGroups = [ "wheel" "gamemode" "nixos-config" ];
    };
    mari = {
      isNormalUser = true;
      extraGroups = [ "wheel" "gamemode" ];
    };
  };

  # Глобальные настройки Home Manager
  home-manager = {
    # Решает проблему конфликта файлов, создавая бэкапы
    backupFileExtension = "bak";
    users = {
      alex = { imports = [ ../hm-modules/common.nix ../hm-modules/alex.nix ]; };
      mari = { imports = [ ../hm-modules/common.nix ../hm-modules/mari.nix ]; };
    };
  };
}
