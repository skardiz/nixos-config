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
          # Элементы списка разделяются пробелами, НЕ запятыми
          "org.kde.plasma.kicker"
          {
            name = "org.kde.plasma.icontasks";
            config.General.launchers = [
              # Элементы этого списка также разделяются пробелами
              "applications:systemsettings.desktop"
              "applications:org.kde.konsole.desktop"
              "applications:org.kde.dolphin.desktop"
              "applications:obsidian.desktop"
              "applications:firefox.desktop"
              "applications:org.telegram.desktop.desktop"
            ];
          }
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
  };
}
