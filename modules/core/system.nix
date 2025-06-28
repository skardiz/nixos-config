# modules/core/system.nix
{ pkgs, lib, config, ... }:

{
  # -------------------------------------------------------------------
  # Настройки Nix
  # -------------------------------------------------------------------
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  # -------------------------------------------------------------------
  # Настройки загрузчика
  # -------------------------------------------------------------------
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  # -------------------------------------------------------------------
  # Основные системные настройки
  # -------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console.keyMap = "ru";

  # -------------------------------------------------------------------
  # Сеть
  # -------------------------------------------------------------------
  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  networking.useNetworkd = true;
  systemd.network.enable = true;
}
