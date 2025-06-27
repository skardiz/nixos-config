# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # 1. Конфигурация оборудования для этого конкретного компьютера
    ./hardware-configuration.nix

    # 2. Импортируем только ОБЩИЕ, переиспользуемые модули
    ../../modules/system.nix
    ../../modules/gaming.nix
    ../../modules/desktop.nix
    ../../modules/services.nix

    # 3. Импортируем модули, нужные ТОЛЬКО для этого хоста
    ../../modules/nvidia.nix   # Так как здесь установлена карта NVIDIA
    ../../modules/amnezia.nix  # VPN-клиент и его конфигурация
  ];

  # --- Специфичные для хоста "shershulya" настройки ---

  # Имя хоста
  networking.hostName = "shershulya";

  # Версия состояния системы (из старого system.nix)
  system.stateVersion = "25.11";

  # Выбор ядра (из старого system.nix)
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Настройка /tmp в оперативной памяти (из старого system.nix)
  fileSystems."/tmp" = {
    device  = lib.mkForce "tmpfs";
    fsType  = lib.mkForce "tmpfs";
    options = [ "rw" "nosuid" "nodev" "noexec" "size=8G" "mode=1777" ];
  };

  # Автологин для пользователя alex (из старого desktop.nix)
  services.displayManager.autoLogin = {
    enable = true;
    user = "alex";
  };

  # Специфичные настройки аудиоустройств (из старого services.nix)
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
  # (Все содержимое из старого users.nix перенесено сюда)
  users.groups.nixos-config = {};

  users.users = {
    alex = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" "nixos-config" ]; };
    mari = { isNormalUser = true; extraGroups = [ "wheel" "gamemode" ]; };
  };

  home-manager = {
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
    users = {
      alex = { imports = [ ../../hm-modules/common.nix ../../hm-modules/alex ]; };
      mari = { imports = [ ../../hm-modules/common.nix ../../hm-modules/mari.nix ]; };
    };
  };
}
