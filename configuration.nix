{ config, pkgs, lib, ... }:

{
  # Подключаем аппаратный файл и конфиг из репозитория
  imports = [
    ./hardware-configuration.nix
    /opt/nixos-timeweb/image.nix
  ];

  # Явно заявляем поддержку btrfs
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  # Загрузчик и параметры загрузки
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";   # если диск иной — замени
  boot.loader.timeout = 0;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.growPartition = true;

  # Сеть
  networking.useDHCP = true;

  # По желанию — SSH-ключ для root
  # users.users.root.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAA... user"
  # ];

  # Версия состояния системы
  system.stateVersion = "24.11";
}
