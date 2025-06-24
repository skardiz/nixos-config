# /home/alex/nixos-config/hm-modules/common.nix
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";

  # Оверлей для rycee больше не нужен, так как мы используем
  # встроенную опцию для языковых пакетов. Убираем его.
  # nixpkgs.overlays = [ ... ];

  home.packages = with pkgs; [
    collabora-online
    cryptpad
    freeoffice
    google-chrome
    kdePackages.calligra
    libreoffice
    obsidian
    onlyoffice-bin
    telegram-desktop
    #wpsoffice
    zapzap
    zoom-us
  ];
}
