# /etc/nixos/modules/system.nix
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.kernelPackages = pkgs.linuxPackages_cachyos; # УДАЛЕНО. Система будет использовать ядро по умолчанию.

  networking.hostName = "shershulya";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow";
}
