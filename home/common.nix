# /home/alex/nixos-config/hm-modules/common.nix
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    google-chrome
    libreoffice
    obsidian
    telegram-desktop
    tree
    zapzap
    zoom-us
  ];
}
