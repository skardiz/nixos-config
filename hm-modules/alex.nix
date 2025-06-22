{ pkgs, ... }:
{
  # Индивидуальные пакеты для alex
  home.packages = with pkgs; [
    firefox
    # Konsole уже является частью окружения Plasma,
    # поэтому добавлять его в пакеты не нужно.
  ];

  # Декларативное управление файлами конфигурации
  home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][2][Applets][3][Configuration][General]
    launchers=applications:org.kde.dolphin.desktop,applications:firefox.desktop,applications:org.kde.konsole.desktop
  '';
}
