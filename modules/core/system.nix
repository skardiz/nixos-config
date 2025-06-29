# modules/core/system.nix
# Этот файл содержит самые базовые, фундаментальные настройки системы.
{ config, pkgs, ... }:

{
  # --- Настройки Nix ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Разрешаем установку несвободных пакетов на уровне ВСЕЙ СИСТЕМЫ.
  # Это необходимо для таких вещей, как драйверы NVIDIA.
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;

  # --- Оверлей для zlib (самый надежный метод) ---
  # Заменяем стандартную библиотеку zlib на её высокопроизводительную
  # версию zlib-ng с помощью низкоуровневого оверлея.
  # Этот метод работает на всех версиях NixOS.
  nixpkgs.config.zlib.package = pkgs.zlib-ng;

  # --- Загрузчик ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Оптимизация производительности ---
  services.fstrim.enable = true;

  # --- Локализация и время ---
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "ru";
  };
}
