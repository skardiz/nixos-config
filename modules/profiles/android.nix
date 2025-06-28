# modules/profiles/android.nix
{ pkgs, ... }:

{
  # Включаем сам сервис WayDroid
  virtualisation.waydroid.enable = true;

  # Добавляем пакет для работы буфера обмена между Android и NixOS
  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];
}
