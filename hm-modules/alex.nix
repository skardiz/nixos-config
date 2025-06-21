# /etc/nixos/hm-modules/alex.nix
# Персональные настройки и пакеты для alex.
{ pkgs, ... }:
{
  programs.git = { userName = "Alex"; userEmail = "alex@example.com"; };
  home.packages = with pkgs; [ firefox ];
}
