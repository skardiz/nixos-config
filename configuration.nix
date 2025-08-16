{ config, pkgs, lib, ... }:

{
  # Импорт аппаратной конфигурации и конфигов из репозитория nixos-timeweb
  imports = [
    ./hardware-configuration.nix
    /opt/nixos-timeweb/image.nix
  ];

  ########################################
  # Файловые системы: Btrfs + субтомы
  ########################################

  # Перебиваем ext4 из импортируемого модуля с помощью mkForce
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
      "noatime"
      "space_cache=v2"
    ];
    autoResize = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
      "space_cache=v2"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd"
      "noatime"
      "space_cache=v2"
    ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=@persist"
      "compress=zstd"
      "noatime"
      "space_cache=v2"
    ];
  };

  # Явно заявляем поддержку btrfs в ядре и initrd
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  ########################################
  # Загрузчик и параметры загрузки
  ########################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";   # у тебя системный диск — /dev/sda
  boot.loader.timeout = 0;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.growPartition = true;

  ########################################
  # Сеть и базовые настройки
  ########################################
  networking.useDHCP = true;

  # Можно сразу добавить ключ для root (раскомментируй и вставь свой)
  # users.users.root.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAA... user"
  # ];

  ########################################
  # Версия состояния системы
  ########################################
  system.stateVersion = "24.11";
}
