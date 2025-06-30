# modules/features/dpi-tunnel.nix
{ pkgs, ... }:
{
  # Включаем наш новый, кастомный пакет
  environment.systemPackages = [ pkgs.dpitunnel ];

  # Создаем сервис
  systemd.services.dpitunnel = {
    description = "DPI Tunnel Proxy Service (C++ version)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      # --- ГЛАВНАЯ МАГИЯ! ---
      # Мы используем первую из двух "магических строк", рекомендованных автором.
      # Мы также правильно указываем путь к сертификатам.
      ExecStart = ''
        ${pkgs.dpitunnel}/bin/dpitunnel \
          --ca-bundle-path=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
          --desync-attacks=fake,disorder_fake \
          --split-position=2 \
          --auto-ttl=1-4-10 \
          --min-ttl=3 \
          --doh \
          --doh-server=https://dns.google/dns-query \
          --wsize=1 \
          --wsfactor=6
      '';
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
