# home/_common/packages.nix
#
# Этот модуль отвечает за управление пакетами для пользователей.
# Он читает "пульт управления" и добавляет нужные пакеты.
{ lib, config, pkgs, ... }:

{
  # Мы определяем здесь ТОЛЬКО конфигурацию, не опции.
  # Опции уже определены в нашем центральном `modules/options.nix`.
  config = {
    # Собираем все пакеты из включенных опций в один список
    home.packages = lib.mkMerge [
      # lib.mkIf <условие> [ <список пакетов> ]
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
