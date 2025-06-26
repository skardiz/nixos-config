# /home/alex/nixos-config/modules/nvidia.nix
{ config, pkgs, ... }:

{
  hardware.graphics = { enable = true; enable32Bit = true; };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}
