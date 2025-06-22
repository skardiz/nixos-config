{ pkgs, inputs, ... }:
{
  users.groups.nixos-config = {};
  users.users = {
    alex = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" "nixos-config" ]; };
    mari = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" ]; };
  };
  home-manager = {
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
    users = {
      alex = { imports = [ ../hm-modules/common.nix ../hm-modules/alex ]; };
      mari = { imports = [ ../hm-modules/common.nix ../hm-modules/mari.nix ]; };
    };
  };
}
