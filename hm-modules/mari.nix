{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    zoom-us
  ];

  # Для mari нет никаких настроек Git.
  # Пакет git не будет установлен для этого пользователя.
}
