# /etc/nixos/hm-modules/mari.nix
# Персональные настройки и пакеты для mari.
{ pkgs, ... }:
{
  programs.git = { userName = "Mari"; userEmail = "mari@example.com"; };
  home.packages = with pkgs; [ google-chrome zoom-us ];
}
