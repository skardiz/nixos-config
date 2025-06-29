# modules/features/desktop.nix
#
# Этот модуль реализует все, что нужно для базового десктопа.
{ pkgs, ... }:
{
  networking.networkmanager.enable = true;
  services.xserver.enable = true;
  services.xserver.xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
