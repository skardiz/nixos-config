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

  # Финальная, 100% правильная конфигурация панели задач через plasma-manager
  programs.plasma = {
    enable = true;
    panels = [
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kicker", # Меню "Пуск"
          {
            name = "org.kde.plasma.icontasks";
            config.General.launchers = [
              "applications:systemsettings.desktop"
              "applications:org.kde.konsole.desktop"
              "applications:org.kde.dolphin.desktop"
              # --- ИСПОЛЬЗУЕМ ТОЧНЫЕ ИМЕНА ИЗ ВАШЕГО ВЫВОДА ---
              "applications:obsidian.desktop"         # Правильное имя, которое вы нашли
              "applications:firefox.desktop"
              "applications:org.telegram.desktop.desktop" # Новое, точное имя для Telegram
            ];
          },
          "org.kde.plasma.systemtray", # Системный трей
          "org.kde.plasma.digitalclock" # Цифровые часы
        ];
      }
    ];
  };
}
