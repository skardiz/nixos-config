# home/_common/options.nix
#
# Единый, идеальный "Пульт Управления" для всех пользовательских конфигураций.
# Здесь мы определяем все "кнопки" и прописываем всю их логику.

{ lib, config, pkgs, ... }:

{
  # --- РАЗДЕЛ 1: ОПРЕДЕЛЯЕМ ВСЕ КНОПКИ ---
  options.my.home = {
    # Твои существующие кнопки для управления пакетами
    packages = {
      common = lib.mkEnableOption "Базовый набор приложений (браузер, офис и т.д.)";
      dev = lib.mkEnableOption "Инструменты для разработки";
    };

    # НАША НОВАЯ КНОПКА
    enableUserSshKey = lib.mkEnableOption "Декларативное управление основным SSH-ключом пользователя";
  };


  # --- РАЗДЕЛ 2: ПРОПИСЫВАЕМ ВСЮ ЛОГИКУ ---
  # Мы используем lib.mkMerge, чтобы безопасно объединить всю логику в один блок.
  config = lib.mkMerge [

    # Блок 1: Существующая логика для пакетов
    {
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
    }

    # Блок 2: НАША НОВАЯ ЛОГИКА для SSH-ключа
    # Она будет работать ТОЛЬКО ЕСЛИ enableAnsibleKey = true;
    (lib.mkIf config.my.home.enableUserSshKey {
      sops.secrets.user_alex_ssh_private_key = {
        sopsFile = ../../secrets.yaml;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
    })

  ];
}
