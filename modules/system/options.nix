# modules/options.nix
#
# Наш центральный "Пульт Управления".
# Здесь мы объявляем все кастомные опции и связываем их с реальными настройками NixOS.
{ lib, config, pkgs, ... }:

{
  # =================================================================
  # РАЗДЕЛ 1: "ПАНЕЛЬ УПРАВЛЕНИЯ" (options.my)
  # Здесь мы объявляем наши собственные, красивые "переключатели".
  # Это наш высокоуровневый API для управления системой.
  # =================================================================
  options.my = {
    locale.enableRussian = lib.mkEnableOption "Полная русификация системы";

    optimizations = {
      enableSsdTweaks = lib.mkEnableOption "Оптимизации для SSD (fstrim)";
      enableZlibNg = lib.mkEnableOption "Высокопроизводительная библиотека zlib-ng";
      enableDesktopResponsiveness = lib.mkEnableOption "Службы для отзывчивости десктопа";
    };

    policies = {
      allowUnfree = lib.mkEnableOption "Разрешить несвободные пакеты";
      enableAutoGc = lib.mkEnableOption "Автоматическая сборка мусора";
      enableFlakes = lib.mkEnableOption "Включить Flakes и nix-command";
    };

    # Наш "Базовый Пакет Коммунальных Услуг"
    services.enableCore = lib.mkEnableOption "Включить базовый набор системных сервисов и утилит";
  };

  # =================================================================
  # РАЗДЕЛ 2: "МАШИННОЕ ОТДЕЛЕНИЕ" (config)
  # Здесь мы связываем наши красивые "переключатели"
  # с реальными, низкоуровневыми настройками NixOS.
  # =================================================================
  config = lib.mkMerge [
    # --- Блок 1: Индивидуальные настройки ---
    {
      time.timeZone = lib.mkIf config.my.locale.enableRussian "Europe/Moscow";
      i18n.defaultLocale = lib.mkIf config.my.locale.enableRussian "ru_RU.UTF-8";
      console.keyMap = lib.mkIf config.my.locale.enableRussian "ru";

      services.fstrim.enable = lib.mkIf config.my.optimizations.enableSsdTweaks true;
      nixpkgs.config.zlib.package = lib.mkIf config.my.optimizations.enableZlibNg pkgs.zlib-ng;

      security.rtkit.enable = lib.mkIf config.my.optimizations.enableDesktopResponsiveness true;
      services.irqbalance.enable = lib.mkIf config.my.optimizations.enableDesktopResponsiveness true;
      services.ananicy.enable = lib.mkIf config.my.optimizations.enableDesktopResponsiveness true;

      nixpkgs.config.allowUnfree = lib.mkIf config.my.policies.allowUnfree true;
      nix.gc = lib.mkIf config.my.policies.enableAutoGc {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      nix.optimise.automatic = lib.mkIf config.my.policies.enableAutoGc true;
      nix.settings.experimental-features = lib.mkIf config.my.policies.enableFlakes [ "nix-command" "flakes" ];
    }

    # --- Блок 2: Наш "Базовый Пакет Коммунальных Услуг" ---
    (lib.mkIf config.my.services.enableCore {
      services.timesyncd.enable = true;
      networking.firewall.enable = true;
      environment.systemPackages = [
        pkgs.git
        pkgs.nix-index
      ];
      programs.nix-index.enable = true;
      programs.command-not-found.enable = false;
    })
  ];
}
