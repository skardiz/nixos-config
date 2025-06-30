# modules/features/android.nix
{ pkgs, lib, ... }: # <-- Убедитесь, что 'lib' здесь есть

{
  virtualisation.waydroid.enable = true;

  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
  # Мы используем lib.mkForce, чтобы принудительно установить НАШЕ значение BusName,
  # игнорируя стандартное значение из модуля waydroid.nix.
  # Это решает конфликт определений.
  systemd.services.waydroid-container.serviceConfig.BusName = lib.mkForce "org.waydroid.container";

  # Ваши существующие настройки для общей папки и утилит остаются
  fileSystems."/var/lib/waydroid/data/media/0/Shared" = {
    device = "/home/shared/waydroid";
    fsType = "none";
    options = [ "bind" ];
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xorg.xwininfo
    xorg.xprop
  ];
}
