# modules/features/smart-dns.nix
#
# Финальная, отказоустойчивая конфигурация для dnscrypt-proxy2.
{ config, pkgs, lib, ... }: # <-- Убедитесь, что 'lib' здесь есть

{
  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
  # Мы используем lib.mkForce, чтобы наш приказ "ВЫКЛЮЧИТЬ"
  # имел наивысший приоритет и отменил приказ "ВКЛЮЧИТЬ" из desktop.nix.
  services.resolved.enable = lib.mkForce false;

  # Включаем наш новый сервис
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

  # Мы добавляем явную зависимость от network-online.target,
  # чтобы сервис стартовал только тогда, когда интернет точно есть.
  systemd.services.dnscrypt-proxy2.after = [ "network-online.target" ];
  systemd.services.dnscrypt-proxy2.wants = [ "network-online.target" ];

  # Указываем системе использовать НАШ локальный DNS-прокси.
  networking.nameservers = [ "127.0.0.1" ];

  # Принудительно отключаем управление DNS через NetworkManager
  networking.networkmanager.dns = lib.mkForce "none";

  # Firewall
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [53 ];
  };
}
