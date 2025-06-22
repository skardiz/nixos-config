{ pkgs, ... }:
{
  # Удаляем home.language.base, так как будем использовать более прямой метод

  home.packages = with pkgs; [ firefox ];

  programs.git = { enable = true; userName = "Alex"; userEmail = "skardizone@gmail.com"; };

  # Прямое управление файлом конфигурации локали KDE
  home.file.".config/plasma-localerc" = {
    text = ''
      [Formats]
      LANG=ru_RU.UTF-8

      [Translations]
      LANG=ru_RU.UTF-8
    '';
  };

  # Конфигурация панели задач остается прежней
  home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][2][Applets][3][Configuration][General]
    launchers=applications:systemsettings.desktop,applications:org.kde.konsole.desktop,applications:org.kde.dolphin.desktop
  '';
}
