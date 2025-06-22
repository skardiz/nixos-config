{ ... }:
{
  # Настройки графического сервера
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
  };

  # Настройки окружения рабочего стола и менеджера входа
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
}
