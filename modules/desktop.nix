{ ... }:
{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
  };

  # Перемещаем опции на верхний уровень в `services`
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
}
