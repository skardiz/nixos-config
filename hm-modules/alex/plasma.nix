# /home/alex/nixos-config/hm-modules/alex/plasma.nix
{ inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeManagerModules."plasma-manager" ];

  home.file.".config/plasma-localerc".text = ''
    [Formats]
    LANG=ru_RU.UTF-8
    [Translations]
    LANG=ru_RU.UTF-8
  '';

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
