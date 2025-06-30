# modules/features/vpn.nix
{ config, pkgs, ... }:

{
  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
  # Мы используем самый правильный и идиоматичный способ для добавления модулей:
  # `with config.boot.kernelPackages;`
  # Это автоматически берет правильный набор пакетов для нашего текущего ядра (Zen)
  # и ищет в нем нужный нам модуль `amneziawg`.
  boot.extraModulePackages = with config.boot.kernelPackages; [ amneziawg ];

  # Устанавливаем необходимые утилиты (без изменений)
  environment.systemPackages = with pkgs; [
    amnezia-vpn
    amneziawg-tools
    amneziawg-go
  ];

  # Конфигурация WireGuard (без изменений)
  networking.wireguard.interfaces.awg0 = {
    privateKey = "2Dlk4WaRdfZ++PKIL1DWg9Kzm1oy2SxzPR/Ae+Oo02U=";
    ips = [ "172.16.0.2/32" "2606:4700:110:8e45:d9ad:5eb1:7ff3:d73c/128" ];
    mtu = 1280;
    peers = [ {
      publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
      endpoint = "188.114.99.224:1002";
      allowedIPs = [ "0.0.0.0/0" "::/0" ];
    } ];
  };

  # Настройки DNS и Firewall (без изменений)
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  networking.firewall.trustedInterfaces = [ "awg0" ];
}
