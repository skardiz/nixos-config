# modules/features/dpi-tunnel.nix
{ pkgs, ... }:

let
  # --- ГЛАВНАЯ МАГИЯ! ---
  # Мы создаем локальную переменную 'dpitunnel' прямо здесь.
  # Мы используем `pkgs.callPackage`, который гарантированно имеет
  # доступ ко всем зависимостям, и указываем ему на наш чертеж.
  # Относительный путь `../../pkgs/dpitunnel` критически важен!
  dpitunnel = pkgs.callPackage ../../pkgs/dpitunnel {};

in
{
  # Создаем системный сервис.
  systemd.services.dpitunnel = {
    description = "DPI Tunnel Proxy Service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # --- ИСПОЛЬЗУЕМ НАШУ ЛОКАЛЬНУЮ СБОРКУ ---
      # Теперь мы используем не `${pkgs.dpitunnel}` (которого не существует
      # на этом этапе), а нашу локальную, собранную вручную переменную.
      ExecStart = ''
        ${dpitunnel}/bin/dpitunnel \
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
