{ pkgs, ... }:
{
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

  # Добавляем эту секцию для настройки поведения Home Manager
  home-manager = {
    # Указываем расширение для бэкапов. 'bak' — хороший выбор.
    backupFileExtension = "bak";
    users = {
      alex = { imports = [ ../hm-modules/common.nix ../hm-modules/alex.nix ]; };
      mari = { imports = [ ../hm-modules/common.nix ../hm-modules/mari.nix ]; };
    };
  };
}
