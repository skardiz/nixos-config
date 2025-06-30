# modules/features/smart-dns.nix
#
# Наш умный DNS-прокси на базе dnscrypt-proxy2.
{ config, pkgs, lib, ... }: # <-- Убедитесь, что 'lib' здесь есть

{
  # Включаем сам сервис
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" ];
      lb_strategy = "p2";
      require_dnssec = true;
      require_nolog = true;
      fallback_resolver = "1.1.1.1:53";
      cache = true;
      cache_size = 512;
    };
  };

  # Указываем системе использовать НАШ локальный DNS-прокси для ВСЕХ запросов.
  networking.nameservers = [ "127.0.0.1" ];

  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
  # Мы используем lib.mkForce, чтобы принудительно установить НАШЕ значение 'none',
  # игнорируя стандартное значение 'systemd-resolved'. Это решает конфликт.
  networking.networkmanager.dns = lib.mkForce "none";
}
