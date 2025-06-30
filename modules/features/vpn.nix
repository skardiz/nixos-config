# modules/features/vpn.nix
#
# Этот модуль декларативно настраивает AmneziaWG,
# храня приватный ключ напрямую в конфигурации.
{ config, pkgs, ... }:

{
  # 1. Подключаем модуль ядра и утилиты (это остается без изменений)
  boot.extraModulePackages = [ config.boot.kernelPackages.amneziawg ];
  environment.systemPackages = with pkgs; [ amneziawg-tools ];

  # 2. Декларативно настраиваем сам интерфейс WireGuard
  networking.wireguard.interfaces = {
    # Даем интерфейсу имя, например, 'awg0'
    awg0 = {
      # ПРИВАТНЫЙ КЛЮЧ: Из секции [Interface] -> PrivateKey
      # ВНИМАНИЕ: Этот ключ будет виден всем пользователям системы в /nix/store
      privateKey = "2Dlk4WaRdfZ++PKIL1DWg9Kzm1oy2SxzPR/Ae+Oo02U=";

      # IP-АДРЕСА: Из секции [Interface] -> Address
      ips = [ "172.16.0.2/32" "2606:4700:110:8e45:d9ad:5eb1:7ff3:d73c/128" ];

      # MTU: Из секции [Interface] -> MTU
      mtu = 1280;

      # Описываем наш Peer (сервер), к которому мы подключаемся
      peers = [
        {
          # ПУБЛИЧНЫЙ КЛЮЧ СЕРВЕРА: Из секции [Peer] -> PublicKey
          publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";

          # АДРЕС СЕРВЕРА: Из секции [Peer] -> Endpoint
          endpoint = "188.114.99.224:1002";

          # РАЗРЕШЕННЫЕ IP: Из секции [Peer] -> AllowedIPs
          # Эта строка говорит: "ВЕСЬ трафик должен идти через этот VPN"
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
        }
      ];
    };
  };

  # 3. Настраиваем DNS
  # Когда VPN активен, система будет использовать эти DNS-серверы
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  # 4. Управляем файрволом
  # Разрешаем весь трафик через наш VPN-интерфейс
  networking.firewall.allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
  networking.firewall.trustedInterfaces = [ "awg0" ];
}
