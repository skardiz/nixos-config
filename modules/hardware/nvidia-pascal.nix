# /home/alex/nixos-config/modules/nvidia.nix
{ config, pkgs, lib, ... }:

{
  # Параметры ядра для корректной работы NVIDIA на Wayland
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia_drm.fbdev=1" "nvidia.NVreg_EnableGpuFirmware=0" ];

  # Новые опции для графики (замена hardware.opengl)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Пакеты для аппаратного ускорения видео
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    forceFullCompositionPipeline = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Переменные окружения для Wayland
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Дополнительные системные пакеты (с исправленными именами)
  environment.systemPackages = with pkgs; [
  ];
}
