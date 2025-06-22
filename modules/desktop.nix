{ ... }:
{
  services.xserver = {
    enable = true;
    xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  # Правильный и надежный способ установить язык для SDDM и всей сессии
  systemd.services.display-manager.environment = {
    LANG = "ru_RU.UTF-8";
    LC_ALL = "ru_RU.UTF-8";
  };
}
