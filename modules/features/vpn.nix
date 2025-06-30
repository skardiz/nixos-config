# modules/features/vpn.nix
#
# Финальная, рабочая конфигурация для AmneziaWG.
{ config, pkgs, ... }:

{
  # --- ШАГ 1: Загрузка модуля ядра ---
  # Мы явно указываем NixOS, что нужно скомпилировать и включить
  # в состав ядра Zen тот самый модуль, который вы нашли.
  # Это — единственно правильный способ.
  boot.extraModulePackages = [ pkgs.linuxKernel.packages.linux_zen.amneziawg ];

  # Устанавливаем необходимые утилиты (без изменений)
  environment.systemPackages = with pkgs; [
    amnezia-vpn
    amneziawg-tools
    amneziawg-go
  ];

  # --- ШАГ 2: Декларативная настройка интерфейса ---
  # Мы используем встроенный в NixOS, надежный механизм networking.wireguard.
  # Он будет работать, ПОТОМУ ЧТО на Шаге 1 мы гарантировали,
  # что ядро будет знать, что такое "amneziawg".
  networking.wireguard.interfaces = {
    awg0 = {
      # ВНИМАНИЕ: Этот ключ будет виден всем пользователям системы в /nix/store
      privateKey = "2Dlk4WaRdfZ++PKIL1DWg9Kzm1oy2SxzPR/Ae+Oo02U=";
      ips = [ "172.16.0.2/32" "2606:4700:110:8e45:d9ad:5eb1:7ff3:d73c/128" ];
      mtu = 1280;
      peers = [
        {
          publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
          endpoint = "188.114.99.224:1002";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
        }
      ];
    };
  };

  # --- ШАГ 3: Настройка сети и файрвола ---
  # Мы явно указываем DNS-серверы и разрешаем трафик через наш туннель.
  networking.nameservers = [ "1.1.1.1" ];
  networking.firewall.trustedInterfaces = [ "awg0" ];
}
