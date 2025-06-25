# /home/alex/nixos-config/modules/hiddify.nix
{ pkgs, ... }:

{
  # 1. Установка пакета hiddify-app (GUI) для всех пользователей системы.
  environment.systemPackages = with pkgs; [
    hiddify-app
  ];

  # 2. Настройка автозапуска ГРАФИЧЕСКОГО приложения (hiddify-app) для всех пользователей.
  environment.etc."xdg/autostart/hiddify-app.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Hiddify App Autostart
    Comment=Starts the Hiddify GUI application on session login
    Exec=${pkgs.hiddify-app}/bin/hiddify-app --autostart
    X-KDE-autostart-condition=ksmserver
    OnlyShowIn=KDE;
  '';

  # --- Встраиваем WARP-конфиг для ручного импорта в Hiddify App ---
  # 3. WARP-конфиг будет доступен в /etc/hiddify-warp-config.conf.
  # Пользователь сможет скопировать его оттуда и импортировать в Hiddify App.
  environment.etc."hiddify-warp-config.conf".text = ''
    [Interface]
    PrivateKey = 2Dlk4WaRdfZ++PKIL1DWg9Kzm1oy2SxzPR/Ae+Oo02U=
    S1 = 0
    S2 = 0
    Jc = 120
    Jmin = 23
    Jmax = 911
    H1 = 1
    H2 = 2
    H3 = 3
    H4 = 4
    MTU = 1280
    Address = 172.16.0.2, 2606:4700:110:8e45:d9ad:5eb1:7ff3:d73c
    DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

    [Peer]
    PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = 188.114.99.224:1002
  '';
  # Права доступа: только root может читать этот файл, чтобы защитить приватный ключ.
  # Пользователь сможет прочитать его с помощью 'sudo cat /etc/hiddify-warp-config.conf'
  environment.etc."hiddify-warp-config.conf".mode = "0400";
}
