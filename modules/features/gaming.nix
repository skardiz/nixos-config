# modules/features/gaming.nix
{ pkgs, ... }:
{
  environment.sessionVariables = { MANGOHUD = "1"; };
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs; [ gamescope ];
}
