{ pkgs, ... }:
{
  # Включаем экспериментальные функции для всей системы
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  i18n.defaultLocale = "ru_RU.UTF-8";
  console.keyMap = "ru";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "shershulya";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow";
}
