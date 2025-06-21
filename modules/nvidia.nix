{ config, pkgs, ... }:

{
  # Включить поддержку графики
  hardware.graphics.enable = true;

  # Использовать проприетарный драйвер NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  # Явно указать использование проприетарного драйвера (для Pascal требуется false)
  hardware.nvidia.open = false;

  # (Необязательно) Указать конкретную ветку драйвера, если нужна стабильность или совместимость
  # По умолчанию используется последняя стабильная версия, но можно явно указать:
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # (Необязательно) Включить nvidia-settings и nvidia-persistenced
  # environment.systemPackages = with pkgs; [ nvidia-settings nvidia-persistenced ];

  # (Необязательно) Включить поддержку CUDA, если требуется
  # hardware.nvidia.cudaSupport = true;
}
