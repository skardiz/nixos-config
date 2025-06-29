# home/_common/default.nix
# Содержит базовые, общие для всех пользователей настройки Home Manager.
{ ... }:
{
  imports = [
    ./git.nix
    # Мы убрали bash.nix, так как решили использовать 'ванильный' bash
    ./waydroid-idle.nix
  ];

  # --- Базовые настройки Home Manager ---
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11"; # Важно для стабильности

  # --- Общие программы, которые действительно нужны всем ---
  # Например, утилиты командной строки
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
