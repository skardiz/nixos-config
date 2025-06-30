# modules/features/smart-dns.nix
#
# Финальная, отказоустойчивая конфигурация для dnscrypt-proxy2.
{ config, pkgs, lib, ... }:

{
  # --- ПРИКАЗ №1: Полностью увольняем старый сервис ---
  # Это гарантирует, что никто другой не займет порт 53.
  services.resolved.enable = false;

  # Включаем наш новый сервис
  services.dnscrypt-proxy2 = {
    enable = true;
    # --- ПРИКАЗ №3: Отключаем сокет-активацию ---
    # Это упрощает запуск и убирает еще один источник гонки состояний.
    socket.enable = false;
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

  # --- ПРИКАЗ №2: Ждем полной готовности сети ---
  # Мы добавляем явную зависимость от network-online.target,
  # чтобы сервис стартовал только тогда, когда интернет точно есть.
  systemd.services.dnscrypt-proxy2.after = [ "network-online.target" ];
  systemd.services.dnscrypt-proxy2.wants = [ "network-online.target" ];

  # Указываем системе использовать НАШ локальный DNS-прокси.
  networking.nameservers = [ "127.0.0.1" ];
  networking.networkmanager.dns = lib.mkForce "none";
}
