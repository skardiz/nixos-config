# /etc/nixos/modules/users.nix
# Определяет системных пользователей и связывает их с конфигурациями Home Manager.
{ pkgs, ... }:
{
  users.users = {
    alex = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" ]; };
    mari = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" ]; };
  };

  home-manager.users = {
    alex = { imports = [ ../hm-modules/common.nix ../hm-modules/alex.nix ]; };
    mari = { imports = [ ../hm-modules/common.nix ../hm-modules/mari.nix ]; };
  };
}
