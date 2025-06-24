# hm-modules/alex/packages.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Здесь будут все персональные пакеты для alex
    zapzap
    altus
    whatsie
    wasistlos
  ];
}
