# modules/core/system.nix
# Этот файл содержит самые базовые, фундаментальные настройки системы.
{ config, pkgs, ... }:

{
  # --- Настройки Nix ---
  # Включаем экспериментальные возможности, необходимые для Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Настраиваем автоматическую очистку мусора для экономии места на диске
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Включаем автоматическую оптимизацию хранилища Nix
  nix.optimise.automatic = true;

  # --- Загрузчик ---
  # Используем systemd-boot, стандартный для систем с UEFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Оптимизация производительности ---
  # Заменяем стандартную библиотеку zlib на её высокопроизводительную
  # версию zlib-ng. Это ускоряет многие системные операции.
  boot.zlib.implementation = "zlib-ng";

  # Включаем еженедельную команду fstrim для SSD-накопителей
  services.fstrim.enable = true;

  # --- Локализация и время ---
  # Устанавливаем часовой пояс
  time.timeZone = "Europe/Moscow";

  # Настраиваем системные локали
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

  # Настраиваем раскладку клавиатуры для консоли (TTY)
  console = {
    font = "Lat2-Terminus16";
    keyMap = "ru";
  };
}
