# /home/alex/nixos-config/hm-modules/alex/firefox.nix
{ pkgs, ... }: # pkgs здесь нужен для возможного добавления расширений в будущем
{
  programs.firefox = {
    enable = true;

    # Шаг 1: Декларативно устанавливаем русский языковой пакет.
    # Это самый важный и правильный шаг.
    languagePacks = [ "ru" ];

    # Шаг 2: Устанавливаем настройки профиля, чтобы Firefox по умолчанию
    # использовал русский язык, даже после сброса.
    profiles.alex = {
      isDefault = true;
      settings = {
        # Принудительно устанавливаем желаемую локаль для интерфейса
        "intl.locale.requested" = "ru";
      };
      # Здесь можно будет добавлять настоящие расширения, если понадобится, например:
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin ];
    };
  };
}
