# /home/alex/nixos-config/modules/hiddify.nix
{ pkgs, ... }:

{
  # Установка пакета для всех пользователей системы
  environment.systemPackages = with pkgs; [
    hiddify-app
  ];

  # Создаем .desktop файл в системной папке автозапуска
  environment.etc."xdg/autostart/hiddify-app.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Hiddify Autostart
    Comment=Start Hiddify App on Plasma session login

    # Путь к исполняемому файлу
    Exec=${pkgs.hiddify-app}/bin/hiddify-app --autostart

    # --- КЛЮЧЕВОЕ ИЗМЕНЕНИЕ ---
    # Условие для запуска только в сессии KDE Plasma.
    # ksmserver - это менеджер сессий KDE.
    X-KDE-autostart-condition=ksmserver

    # Запускать только в среде Plasma
    OnlyShowIn=KDE;
  '';
}
