{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  # Устанавливаем наш кастомный скрипт как системный пакет
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "rebuild" (builtins.readFile ../scripts/rebuild.sh))
  ];

  i18n.defaultLocale = "ru_RU.UTF-8";
  console.keyMap = "ru";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "shershulya";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow";
}
