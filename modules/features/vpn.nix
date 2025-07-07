# modules/features/vpn.nix

# Финальная, рабочая конфигурация для AmneziaWG,
# основанная на вашем новом, победном шаблоне.
{ config, pkgs, ... }:

{
  # 1. Загрузка модуля ядра (остается без изменений)
  boot.extraModulePackages = [ pkgs.linuxKernel.packages.linux_zen.amneziawg ];

  # 2. Утилиты (остаются без изменений)
  environment.systemPackages = with pkgs; [
    amnezia-vpn
    amneziawg-tools
    amneziawg-go
  ];

  # 3. Новый конфигурационный файл
  environment.etc."amnezia/amneziawg/awg0.conf" = {
    text = ''
      [Interface]
      # ВАЖНО: Вставь сюда свой СУЩЕСТВУЮЩИЙ PrivateKey!
      PrivateKey = ${vpnKey}
      Address = 10.8.0.4/24
      DNS = 1.1.1.1
      Jc = 9
      Jmin = 50
      Jmax = 1000
      S1 = 100
      S2 = 75
      H1 = 1583110509
      H2 = 1884699694
      H3 = 538034460
      H4 = 1051564253

      [Peer]
      PublicKey = wNeK1oGyI7fVtLMI4lzFKllowEvuw72VV/F4k/uX9xk=
      PresharedKey = PFLFbHnr1Wuctm6JuSukg73/xxHohmNZ3IPsYvKpImY=
      AllowedIPs = 0.0.0.0/0, ::/0
      PersistentKeepalive = 0
      Endpoint = 185.125.200.148:51820
    '';
    # Устанавливаем права "только для чтения" для root
    mode = "0400";
  };

  # 4. Надежный сервис systemd (остается без изменений)
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
