{ pkgs, ... }:
{
  # Принудительно устанавливаем русский язык для сессии пользователя
  home.language.base = "ru_RU.UTF-8";

  home.packages = with pkgs; [
    google-chrome
    zoom-us
  ];
}
