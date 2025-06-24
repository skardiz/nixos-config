{ config, pkgs, ... }:
{
  hardware.graphics = { enable = true; enable32Bit = true; };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    # Меняем powerManagement.enable на true
    powerManagement.enable = true;
    open = false; # Используем проприетарные драйверы
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Убираем nvidiaConfig, так как powerManagement.enable должен управлять этим
    # Если проблемы сохранятся, мы вернемся к более тонким настройкам
  };
}
