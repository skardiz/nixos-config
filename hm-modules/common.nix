# /etc/nixos/hm-modules/common.nix
# Общие настройки и программы для всех пользователей.
{ pkgs, ... }:
{
  # ДОБАВЛЕНО: Глобально разрешаем несвободные пакеты ДЛЯ HOME MANAGER.
  # Это необходимо для Obsidian, Chrome, Zoom и т.д.
  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    telegram-desktop
    obsidian
    htop
  ];

  programs.git.enable = true;
}
