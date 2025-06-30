# home/_common/default.nix
{ pkgs, ... }:
{
  imports = [
    # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
    # Подключаем наш новый "Пульт Управления"
    ./options.nix

    ./git.nix
    ./waydroid-idle.nix
  ];

  # Базовые настройки Home Manager (без изменений)
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";

  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
  # Убираем жестко закодированный список пакетов
  # home.packages = [ ... ];

  # Декларативно включаем наборы пакетов, общие для всех пользователей
  my.home.packages = {
    common = true; # Включаем базовый набор для всех
  };
}
