# modules/core/system.nix
{ pkgs, lib, config, ... }:

{
  # -------------------------------------------------------------------
  # Настройки Nix
  # -------------------------------------------------------------------
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  # -------------------------------------------------------------------
  # Настройки загрузчика
  # -------------------------------------------------------------------
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  # -------------------------------------------------------------------
  # Твики производительности (БЕЗ ФАЙЛОВОЙ СИСТЕМЫ)
  # -------------------------------------------------------------------
  services.fstrim.enable = true; # Это безопасная и полезная опция для SSD
  boot.kernelParams = [ "scsi_mod.use_blk_mq=1" "elevator=kyber" ];

  # --- Секция BTRFS полностью удалена ---

  # Параметры ядра для максимальной производительности
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "kernel.split_lock_mitigate" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.page-cluster" = 0;
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
  };

  # Включаем RTKit для аудио и других приложений с низкой задержкой
  security.rtkit.enable = true;

  # --- Демоны-оптимизаторы ---
  services.irqbalance.enable = true;
  services.ananicy.enable = true;

  # -------------------------------------------------------------------
  # Основные системные настройки
  # -------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console.keyMap = "ru";

  # -------------------------------------------------------------------
  # Сеть
  # -------------------------------------------------------------------
  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  networking.useNetworkd = true;
  systemd.network.enable = true;
}
