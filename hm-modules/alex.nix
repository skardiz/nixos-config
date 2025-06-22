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
          # 1. Меню "Пуск"
          "org.kde.plasma.kicker"

          # 2. Менеджер задач с закрепленными приложениями
          {
            name = "org.kde.plasma.icontasks";
            config.General.launchers = [
              "applications:systemsettings.desktop"
              "applications:org.kde.konsole.desktop"
              "applications:org.kde.dolphin.desktop"
              "applications:appimagekit_972a71f0a155c4a56973305b0797321c-obsidian.desktop"
              "applications:firefox.desktop"
              "applications:telegramdesktop.desktop"
            ];
          }

          # 3. Системный трей
          "org.kde.plasma.systemtray"

          # 4. Цифровые часы
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
  };
}
