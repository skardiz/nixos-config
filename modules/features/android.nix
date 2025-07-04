# modules/features/android.nix
#
# Теперь Waydroid не будет запускаться автоматически при старте системы
# или при пересборке. Он будет управляться вручную.
{ pkgs, config, lib, ... }: # <-- config нужен для homeDirectory

{
  # --- ИЗМЕНЕНИЕ ---
  # Убираем enable = true; - теперь сервис не будет автоматически включаться.
  virtualisation.waydroid.enable = false;

  # --- УБИРАЕМ ЭТОТ БЛОК ---
  # TimeoutStartSec больше не нужен, т.к. сервис не запускается автоматически
  # systemd.services.waydroid-container.serviceConfig = {
  #   TimeoutStartSec = "5min";
  # };
  # --- КОНЕЦ УБИРАЕМ ---

  # Твои существующие настройки для общей папки и утилит остаются.
  # Я немного улучшил путь, чтобы он не был захардкожен.
  fileSystems."/var/lib/waydroid/data/media/0/Shared" = {
    device = config.home-manager.users.alex.home.homeDirectory + "/Shared/waydroid";
    fsType = "none";
    options = [ "bind" ];
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xorg.xwininfo
    xorg.xprop
  ];
}
