# hosts/shershulya/default.nix
# Этот файл теперь отвечает ТОЛЬКО за то, что уникально для машины 'shershulya'.
{ config, pkgs, inputs, lib, ... }:
let
  publish-script = pkgs.writeShellScriptBin "publish" (builtins.readFile ../../scripts/publish.sh);
  cleaner-script = pkgs.writeShellScriptBin "cleaner" (builtins.readFile ../../scripts/cleaner.sh);
in
{
  imports = [
    # Подключаем "Конституцию", которая уже включает в себя все необходимое
    ../_common/default.nix

    # Подключаем УНИКАЛЬНУЮ конфигурацию железа
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia-pascal.nix
  ];

  # НАСТРОЙКИ, ДЕЙСТВИТЕЛЬНО УНИКАЛЬНЫЕ ДЛЯ ЭТОГО ХОСТА
  networking.hostName = "shershulya";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  services.resolved.enable = true;

  users.users = {
    alex = { isNormalUser = true; description = "Alex"; extraGroups = [ "wheel" "networkmanager" "video" "adbusers" ]; };
    mari = { isNormalUser = true; description = "Mari"; extraGroups = [ "wheel" "networkmanager" "video" ]; };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; }; # <-- Важная строка для передачи inputs в home
    users = {
      alex = import ../../home/alex;
      mari = import ../../home/mari;
    };
  };

  environment.systemPackages = [ publish-script cleaner-script ];
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "alex";
}
