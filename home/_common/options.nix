# home/_common/options.nix
# "Пульт Управления" для всех пользовательских конфигураций.
{ lib, config, pkgs, ... }:
{
  options.my.home.packages = {
    common = lib.mkEnableOption "Базовый набор приложений (браузер, офис и т.д.)";
    dev = lib.mkEnableOption "Инструменты для разработки";
    # Здесь можно добавлять другие группы: 'gaming', 'design' и т.д.
  };

  config = {
    # Собираем все пакеты из включенных опций в один список
    home.packages = lib.mkMerge [
      (lib.mkIf config.my.home.packages.common [
        pkgs.google-chrome
        pkgs.libreoffice
        pkgs.obsidian
        pkgs.telegram-desktop
        pkgs.tree
        pkgs.zapzap
        pkgs.zoom-us
      ])
      (lib.mkIf config.my.home.packages.dev [
        pkgs.vscode
        pkgs.git-lfs
      ])
    ];
  };
}
