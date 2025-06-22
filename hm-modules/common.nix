{ pkgs, ... }:
{
  # Возвращаем эту строку, чтобы разрешить несвободные пакеты
  # именно для окружения Home Manager.
  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    telegram-desktop
    obsidian # <-- Пакет, вызвавший ошибку
  ];
}
