# modules/features/vpn.nix
#
# Финальная, рабочая конфигурация для AmneziaWG,
# основанная на вашем проверенном шаблоне и новых данных.
{ config, pkgs, ... }:

{
  # 1. Загрузка модуля ядра для Zen (это правильно и остается)
  boot.extraModulePackages = [ pkgs.linuxKernel.packages.linux_zen.amneziawg ];

  # 2. Утилиты (остаются)
  environment.systemPackages = with pkgs; [
    amnezia-vpn
    amneziawg-tools
    amneziawg-go
  ];

  # 3. Конфигурационный файл (Ключевое изменение!)
  # Мы создаем конфигурационный файл, используя данные из вашего нового WARP-1.conf.
  environment.etc."amnezia/amneziawg/awg0.conf" = {
    text = ''
      [Interface]
      PrivateKey = ${vpnKey}
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
      Address = 172.16.0.2, 2606:4700:110:81f5:76e4:76c5:2820:772d
      DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

      [Peer]
      PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
      AllowedIPs = 0.0.0.0/0, ::/0
      Endpoint = 188.114.99.224:1002
    '';
    # Устанавливаем права "только для чтения" для root
    mode = "0400";
  };

  # 4. Надежный сервис systemd (остается без изменений)
  # Мы используем проверенный способ запуска через awg-quick.
  systemd.services.amnezia-vpn = {
    description = "AmneziaWG auto-connect service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.amneziawg-tools}/bin/awg-quick up awg0";
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0";
    };
  };
}
