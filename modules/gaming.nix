{ pkgs, ... }:
{
  environment.sessionVariables = { MANGOHUD = "1"; };
  programs.nix-ld.enable = true;
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamemode.enable = true;
}
