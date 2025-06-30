# modules/features/dpi-tunnel.nix
{ pkgs, ... }:
{
  # Создаем системный сервис, который будет запускать наш "лазерный резак".
  systemd.services.dpitunnel = {
    description = "DPI Tunnel Proxy Service";
    # Запускаем после того, как сеть будет готова.
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # Включаем при загрузке системы.
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # --- ГЛАВНАЯ МАГИЯ! ---
      # Мы используем первую из двух "магических строк", рекомендованных автором.
      # Мы также правильно указываем путь к корневым сертификатам.
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

      # Автоматически перезапускать, если он упадет.
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
