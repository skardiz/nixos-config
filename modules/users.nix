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
