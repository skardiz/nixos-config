# /home/alex/nixos-config/modules/amnezia.nix
{ config, pkgs, ... }:

{
  # 1. Загружаем модуль ядра AmneziaWG при старте системы.
  # Это самый важный шаг для производительности и стабильности.
  boot.extraModulePackages = with config.boot.kernelPackages; [
    amneziawg
  ];

  # 2. Устанавливаем необходимые пакеты для всех пользователей.
  environment.systemPackages = with pkgs; [
    amnezia-vpn       # Графический клиент Amnezia
    amneziawg-tools   # Консольные утилиты, включая awg-quick
  ];

  # 3. Декларативно создаем файл конфигурации для нашего VPN-подключения.
  # NixOS поместит этот файл в /etc/amneziawg/awg0.conf
  environment.etc."amneziawg/awg0.conf".text = ''
    # --- ТВОЙ WARP-КОНФИГ НАЧИНАЕТСЯ ЗДЕСЬ ---
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
    # --- ТВОЙ WARP-КОНФИГ ЗАКАНЧИВАЕТСЯ ЗДЕСЬ ---
  '';
  # Устанавливаем права доступа, чтобы только root мог читать конфиг с ключами
  environment.etc."amneziawg/awg0.conf".mode = "0400";


  # 4. Создаем systemd-сервис для автоматического подключения.
  # Он будет использовать `awg-quick` для управления соединением.
  systemd.services.amnezia-vpn = {
    description = "AmneziaWG auto-connect service";
    # Запускать после того, как сеть будет доступна
    after = [ "network-online.target" ];
    # Включаем сервис в стандартный запуск системы
    wantedBy = [ "multi-user.target" ];

    # Указываем, какие команды выполнять для старта, остановки и перезагрузки
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; # Сервис считается активным после запуска
      ExecStart = "${pkgs.amneziawg-tools}/bin/awg-quick up awg0";
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0";
      ExecReload = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0 && ${pkgs.amneziawg-tools}/bin/awg-quick up awg0";
    };
  };
}
