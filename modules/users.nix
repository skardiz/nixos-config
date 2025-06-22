{ pkgs, inputs, ... }: # Добавляем `inputs`
{
  users.groups.nixos-config = {};
  users.users = {
    alex = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" "nixos-config" ]; };
    mari = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" ]; };
  };
  home-manager = {
    backupFileExtension = "bak";
    # Передаем `specialArgs` в Home Manager
    extraSpecialArgs = { inherit inputs; };
    users = {
      alex = { imports = [ ../hm-modules/common.nix ../hm-modules/alex.nix ]; };
      mari = { imports = [ ../hm-modules/common.nix ../hm-modules/mari.nix ]; };
    };
  };
}
