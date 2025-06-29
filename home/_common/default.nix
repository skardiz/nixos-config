# home/_common/default.nix
# Содержит базовые, общие для всех пользователей настройки Home Manager.
{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./waydroid-idle.nix
  ];

  # --- Базовые настройки Home Manager ---
  # УДАЛЕНО: nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11"; # Важно для стабильности

  # --- Пакеты, которые будут установлены для всех пользователей ---
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
