# hosts/shershulya/default.nix

{ config, pkgs, inputs, lib, ... }:

# --- Локальные переменные для этого модуля ---
let
  publish-script = pkgs.writeShellScriptBin "publish" (
    builtins.readFile ../../scripts/publish.sh
  );
  cleaner-script = pkgs.writeShellScriptBin "cleaner" (
    builtins.readFile ../../scripts/cleaner.sh
  );
in

# --- Основная конфигурация хоста ---
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/system.nix
    ../../modules/core/services.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/profiles/desktop.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/vpn.nix
    ../../modules/profiles/android.nix
  ];

  # --- Сетевые настройки ---
  networking.hostName = "shershulya";

  # --- Системные службы ---
  # Включаем системную службу управления DNS.
  # Это необходимо для корректной работы NetworkManager и многих VPN-клиентов.
  services.resolved.enable = true;

  # --- Версия системы и ядро ---
  system.stateVersion = "25.11";
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # --- Безопасность и права доступа ---
  security.sudo.extraRules = [{
    users = [ "alex" "mari" ];
    commands = [{
      command = "${pkgs.systemd}/bin/systemctl stop waydroid-container.service";
      options = [ "NOPASSWD" ];
    }];
  }];

  # --- Настройки дисплейного менеджера ---
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "alex";

  # --- Системные пакеты и скрипты ---
  environment.systemPackages = [
    publish-script
    cleaner-script
  ];

  # --- Специфичные для оборудования настройки ---
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

  # --- "Паспортный стол": Определяем всех системных пользователей ---
  users.users = {
    alex = {
      isNormalUser = true;
      description = "Alex";
      # Добавляем группу 'adbusers', необходимую для WayDroid
      extraGroups = [ "wheel" "networkmanager" "video" "adbusers" ];
    };
    mari = {
      isNormalUser = true;
      description = "Mari";
      extraGroups = [ "wheel" "networkmanager" "video" ];
    };
  };

  # --- "Министерство ЖКХ": Настраиваем Home Manager ---
  home-manager = {
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
    users = {
      alex = import ../../home/alex;
      mari = import ../../home/mari;
    };
  };
}
