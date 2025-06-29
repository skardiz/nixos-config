# modules/features/desktop.nix
{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  # Правильный и надежный способ установить язык для SDDM
  systemd.services.display-manager.environment = {
    LANG = "ru_RU.UTF-8";
    LC_ALL = "ru_RU.UTF-8";
  };

  # Сеть и звук
  networking.networkmanager.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

}
