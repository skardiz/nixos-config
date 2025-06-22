{ ... }:
{
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Новая, правильная структура для настроек клавиатуры
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
  };
}
