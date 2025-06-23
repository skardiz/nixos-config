# modules/system.nix
{ pkgs, ... }:

{
  # -------------------------------------------------------------------
  # Настройки Nix (включая очистку и оптимизацию)
  # -------------------------------------------------------------------
  nix = {
    # Включаем экспериментальные функции. `flakes` обязательны для работы вашей конфигурации.
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true; # Включает оптимизацию "на лету"
    };

    # Автоматическая сборка мусора
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Полная автоматическая оптимизация хранилища
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  # -------------------------------------------------------------------
  # Основные системные настройки
  # -------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console.keyMap = "ru";

  # -------------------------------------------------------------------
  # Настройки оборудования и загрузки
  # -------------------------------------------------------------------
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -------------------------------------------------------------------
  # Сеть и системные пакеты
  # -------------------------------------------------------------------
  networking.hostName = "shershulya";
  networking.networkmanager.enable = true;

  # Устанавливаем наш кастомный скрипт как системный пакет
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "rebuild" (builtins.readFile ../scripts/rebuild.sh))
  ];
}
