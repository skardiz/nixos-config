{ pkgs, inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeManagerModules."plasma-manager" ];

  home.packages = with pkgs; [ firefox ];

  programs.git = {
    enable = true;
    userName = "Alex";
    userEmail = "skardizone@gmail.com";
  };
  services.ssh-agent.enable = true;

  home.file.".config/plasma-localerc".text = ''
    [Formats]
    LANG=ru_RU.UTF-8
    [Translations]
    LANG=ru_RU.UTF-8
  '';

  # Финальная, правильная конфигурация панели задач через plasma-manager
  programs.plasma = {
    enable = true;
    panels."Панель".widgets = [
      "org.kde.plasma.kicker.desktop" # Пуск
      "systemsettings.desktop"          # Настройки
      "org.kde.konsole.desktop"         # Консоль
      "org.kde.dolphin.desktop"         # Dolphin
      "appimagekit_972a71f0a155c4a56973305b0797321c-obsidian.desktop" # Obsidian
      "firefox.desktop"                 # Firefox
      "telegramdesktop.desktop"         # Telegram
    ];
  };
}
