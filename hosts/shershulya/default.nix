# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

# --- Локальные переменные для этого модуля ---
# Сначала определяем наши кастомные скрипты как пакеты.
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

  # --- Версия системы и ядро ---
  system.stateVersion = "25.11";
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # --- Безопасность и права доступа ---
  # Разрешаем пользователям alex и mari останавливать сервис WayDroid без пароля
  security.sudo.extraRules = [
    {
      users = [ "alex" "mari" ];
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl stop waydroid-container.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # --- Настройки дисплейного менеджера ---
  # Включаем автоматический вход для пользователя 'alex'
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "alex";

  # --- Системные пакеты и скрипты ---
  # Добавляем созданные нами пакеты-скрипты в системные пакеты.
  # Теперь они будут доступны в PATH для всех пользователей.
  environment.systemPackages = [
    publish-script
    cleaner-script
  ];

  # --- Специфичные для оборудования настройки ---
  # Настройки аудиоустройств для PipeWire
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

  # --- Управление пользователями через Home Manager ---
  home-manager = {
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
    users = {
      alex = import ../../home/alex;
      mari = import ../../home/mari;
    };
  };
}
