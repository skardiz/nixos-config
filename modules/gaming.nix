# /etc/nixos/modules/gaming.nix
# Все, что нужно для игр: Steam и системные твики.
{ pkgs, ... }:
{
  environment.sessionVariables = { MANGOHUD = "1"; };
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamemode.enable = true;
}
