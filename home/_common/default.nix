# home/_common/default.nix
# Содержит базовые, общие для всех пользователей настройки Home Manager.

# Явно просим передать нам 'pkgs' и другие инструменты
{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./waydroid-idle.nix
  ];

  # --- Базовые настройки Home Manager ---
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11"; # Важно для стабильности

  # --- Общие программы, которые действительно нужны всем ---
  # Теперь Nix знает, что такое 'pkgs', и эта строка будет работать
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
