{ pkgs, inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeManagerModules."plasma-manager" ];

  home.packages = with pkgs; [
    # Пакет firefox теперь будет управляться через programs.firefox,
    # поэтому его можно убрать отсюда, если он был здесь.
    # Но он у вас был установлен глобально, так что все в порядке.
  ];

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

  # Декларативная настройка Firefox
  programs.firefox = {
    enable = true;
    profiles.alex = {
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # Устанавливаем русский языковой пакет как расширение
        { package = pkgs.firefox-i18n-ru; }
      ];
      # Здесь же можно настраивать и другие вещи, например:
      # settings = {
      #   "browser.startup.homepage" = "https://nixos.org";
      #   "browser.search.region" = "RU";
      # };
    };
  };

  # Конфигурация панели задач через plasma-manager
  programs.plasma = {
    enable = true;
    panels = [
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kicker"
          {
            name = "org.kde.plasma.icontasks";
            config.General.launchers = [
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
