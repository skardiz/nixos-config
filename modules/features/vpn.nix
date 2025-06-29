# modules/features/vpn.nix
{ config, pkgs, ... }:
{
  # Используем config.boot.kernelPackages, чтобы автоматически
  # подхватывать правильный модуль для вашего текущего ядра (включая Zen).
  boot.extraModulePackages = [ config.boot.kernelPackages.amneziawg ];

  environment.systemPackages = with pkgs; [
    amnezia-vpn
    amneziawg-tools
    amneziawg-go
  ];

  environment.etc."amnezia/amneziawg/awg0.conf" = {
    text = ''
      [Interface]
      PrivateKey = 2Dlk4WaRdfZ++PKIL1DWg9Kzm1oy2SxzPR/Ae+Oo02U=
      MTU = 1280
      Address = 172.16.0.2, 2606:4700:110:8e45:d9ad:5eb1:7ff3:d73c
      DNS = 1.1.1.1, 2606:4700:4700::1111
      [Peer]
      PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
      AllowedIPs = 0.0.0.0/0, ::/0
      Endpoint = 188.114.99.224:1002
    '';
    mode = "0400";
  };

  systemd.services.amnezia-vpn = {
    description = "AmneziaWG auto-connect service";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.amneziawg-tools}/bin/awg-quick up awg0";
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0";
    };
  };
}
