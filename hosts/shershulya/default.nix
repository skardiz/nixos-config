# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }: # Убрали 'self' из аргументов

{
  imports = [
    # Конфигурация оборудования для этого конкретного компьютера
    ./hardware-configuration.nix

    # --- Core Modules ---
    ../../modules/core/system.nix
    ../../modules/core/services.nix

    # --- Hardware Modules ---
    ../../modules/hardware/nvidia-pascal.nix

    # --- Profile Modules ---
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/vpn.nix
  ];

  # Специфичные для хоста настройки
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  # Выбор ядра
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Настройка /tmp в оперативной памяти
  fileSystems."/tmp" = {
    device  = lib.mkForce "tmpfs";
    fsType  = lib.mkForce "tmpfs";
    options = [ "rw" "nosuid" "nodev" "noexec" "size=8G" "mode=1777" ];
  };

  # Автологин для пользователя alex
  services.displayManager.autoLogin = {
    enable = true;
    user = "alex";
  };

  # Специфичные настройки аудиоустройств
  environment.etc."wireplumber/main.lua.d/51-default-devices.lua".text = ''
    rule = {
      matches = { { "node.name", "equals", "alsa_output.pci-0000_00_1f.3.analog-stereo" } },
      apply_properties = { ["node.priority"] = 2001 }
    }
    rule = {
      matches = { { "node.name", "equals", "alsa_input.usb-Razer_Inc._Razer_Seiren_Pro_UC1712132400427-00.analog-stereo" } },
      apply_properties = { ["node.priority"] = 2001 }
    }
  '';

  # --- Определение пользователей и Home Manager для этого хоста ---
  users.groups.nixos-config = {};

  # --- Возвращаем ручное определение пользователей ---
  users.users = {
    alex = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" "nixos-config" ]; };
    mari = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" ]; };
  };

  home-manager = {
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
    users = {
      alex = { imports = [ ../../home/common.nix ../../home/alex ]; };
      mari = { imports = [ ../../home/common.nix ../../home/mari.nix ]; };
    };
  };

  # Интеграция системного скрипта cleaner
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "cleaner" (builtins.readFile ../../scripts/cleaner.sh))
  ];
}
