# /home/alex/nixos-config/modules/hiddify.nix
{ pkgs, ... }:

{
  # 1. Устанавливаем hiddify-app (GUI) для всех пользователей системы.
  # Эта опция гарантирует, что симлинк на hiddify-app будет в /run/current-system/sw/bin
  # и, следовательно, в системном PATH.
  environment.systemPackages = with pkgs; [
    hiddify-app
  ];

  # 2. Настройка автозапуска ГРАФИЧЕСКОГО приложения для всех пользователей.
  environment.etc."xdg/autostart/hiddify-app.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Hiddify App Autostart
    Comment=Starts the Hiddify GUI application on session login
    # --- КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: Исправляем путь к исполняемому файлу ---
    Exec=${pkgs.hiddify-app}/bin/hiddify-app
    X-KDE-autostart-condition=ksmserver
    OnlyShowIn=KDE;
  '';
}
