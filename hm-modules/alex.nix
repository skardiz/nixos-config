{ pkgs, ... }:
{
  # Принудительно устанавливаем русский язык для сессии пользователя
  home.language.base = "ru_RU.UTF-8";

  home.packages = with pkgs; [
    firefox
  ];

  programs.git = {
    enable = true;
    userName = "Alex";
    userEmail = "skardizone@gmail.com";
  };

  # Закрепление значков на панели задач.
  # ПРИМЕЧАНИЕ: Если это не сработает, откройте файл
  # ~/.config/plasma-org.kde.plasma.desktop-appletsrc
  # и найдите правильные номера для [Containments][X][Applets][Y]
  home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][2][Applets][3][Configuration][General]
    launchers=applications:systemsettings.desktop,applications:org.kde.konsole.desktop,applications:org.kde.dolphin.desktop
  '';
}
