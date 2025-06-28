# modules/profiles/android.nix
{ pkgs, ... }:

{
  # Включаем базовую поддержку WayDroid
  virtualisation.waydroid.enable = true;

  # Декларативно включаем автозапуск системного контейнера
  systemd.services.waydroid-container.wantedBy = [ "multi-user.target" ];

  # Добавляем вспомогательные пакеты, нужные для работы и для скрипта-сторожа
  # Их нужно установить системно, чтобы они были доступны всем
  environment.systemPackages = with pkgs; [
    wl-clipboard # Для буфера обмена
    xorg.xwininfo # Для скрипта-сторожа
    xorg.xprop    # Для скрипта-сторожа
  ];
}
