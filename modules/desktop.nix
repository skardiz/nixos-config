# /etc/nixos/modules/desktop.nix
# Настройки рабочего стола и графического окружения.
{ ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
}
