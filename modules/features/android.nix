# modules/features/android.nix
#
# Здесь мы разрываем порочный круг бесконечной рекурсии.
{ pkgs, ... }: # Убрали 'config' и 'lib', они здесь больше не нужны

{
  # Мы оставляем Waydroid выключенным по умолчанию. Это правильная стратегия.
  virtualisation.waydroid.enable = false;

  # Твои настройки для утилит остаются.
  environment.systemPackages = with pkgs; [
    wl-clipboard
    xorg.xwininfo
    xorg.xprop
  ];

  # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
  # Мы больше не спрашиваем у системы, где находится твой дом.
  # Мы говорим ей это прямо. Мы жестко прописываем путь.
  fileSystems."/var/lib/waydroid/data/media/0/Shared" = {
    device = "/home/alex/Shared/waydroid"; # <-- ХИРУРГИЧЕСКИЙ РАЗРЕЗ
    fsType = "none";
    options = [ "bind" ];
  };
  # --- КОНЕЦ ЛЕКАРСТВА ---
}
