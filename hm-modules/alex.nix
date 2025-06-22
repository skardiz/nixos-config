{ pkgs, ... }:
{
  home.packages = with pkgs; [ firefox ];
  programs.git = {
    enable = true;
    userName = "Alex";
    userEmail = "skardizone@gmail.com";
  };
  programs.ssh.startAgent = true;
  home.file.".config/plasma-localerc" = {
    text = ''
      [Formats]
      LANG=ru_RU.UTF-8
      [Translations]
      LANG=ru_RU.UTF-8
    '';
  };
  home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][2][Applets][3][Configuration][General]
    launchers=applications:systemsettings.desktop,applications:org.kde.konsole.desktop,applications:org.kde.dolphin.desktop
  '';
}
