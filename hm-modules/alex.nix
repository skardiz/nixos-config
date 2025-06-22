{ pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox
  ];

  # Вся конфигурация Git теперь находится здесь,
  # только для пользователя alex.
  programs.git = {
    enable = true;
    userName = "Alex";
    userEmail = "skardizone@gmail.com";
  };

  home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][2][Applets][3][Configuration][General]
    launchers=applications:systemsettings.desktop,applications:org.kde.konsole.desktop,applications:org.kde.dolphin.desktop
  '';
}
