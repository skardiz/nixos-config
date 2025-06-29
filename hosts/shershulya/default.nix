# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:
let
  publish-script = pkgs.writeShellScriptBin "publish" (builtins.readFile ../../scripts/publish.sh);
  cleaner-script = pkgs.writeShellScriptBin "cleaner" (builtins.readFile ../../scripts/cleaner.sh);
in
{
  imports = [
    # --- Подключаем наши модульные компоненты ---
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia-pascal.nix

    # Наш новый "Пульт Управления"
    ../../modules/options.nix

    # Наша библиотека "фич"
    ../../modules/features/desktop.nix
    ../../modules/features/gaming.nix
    ../../modules/features/android.nix
  ];

  # ------------------------------------------------------------------
  # "ПУЛЬТ УПРАВЛЕНИЯ" ДЛЯ ЭТОГО ХОСТА
  # ------------------------------------------------------------------
  my = {
    locale.enableRussian = true;
    optimizations = {
      enableSsdTweaks = true;
      enableZlibNg = true;
      enableDesktopResponsiveness = true;
    };
    policies = {
      allowUnfree = true;
      enableAutoGc = true;
      enableFlakes = true;
    };
  };

  # ------------------------------------------------------------------
  # НАСТРОЙКИ, УНИКАЛЬНЫЕ ДЛЯ ЭТОГО ХОСТА
  # ------------------------------------------------------------------
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  services.resolved.enable = true;

  users.users = {
    alex = { isNormalUser = true; description = "Alex"; extraGroups = [ "wheel" "networkmanager" "video" "adbusers" ]; };
    mari = { isNormalUser = true; description = "Mari"; extraGroups = [ "wheel" "networkmanager" "video" ]; };
  };

  home-manager.users = {
    alex = import ../../home/alex;
    mari = import ../../home/mari;
  };

  environment.systemPackages = [ publish-script cleaner-script ];
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "alex";
}
