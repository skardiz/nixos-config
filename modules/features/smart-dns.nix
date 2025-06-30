# modules/features/smart-dns.nix
#
# Финальная конфигурация для dnscrypt-proxy2, адаптированная
# для работы в условиях ограничений.
{ config, pkgs, lib, ... }:

{
  # Полностью отключаем старый сервис, чтобы избежать конфликтов.
  services.resolved.enable = lib.mkForce false;

  # Включаем наш новый, умный DNS-прокси.
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" ];

      # Указываем список предпочтительных серверов.
      server_names = [
        "yandex-dns"
        "adguard-dns"
        "scaleway-fr"
        "quad9-dnscrypt-ip4-filter-pri"
      ];

      # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
      # Мы переписываем [anonymized_dns] на правильный синтаксис языка Nix:
      # имя_атрибута = { ... };
      anonymized_dns = {
        routes = [
          { server_name="scaleway-fr"; via=["yandex-dns"]; }
        ];
      };

      # Резервный DNS, если что-то пойдет не так при первом запуске
      fallback_resolver = "1.1.1.1:53";

      # Включаем кеширование для ускорения повторных запросов
      cache = true;
      cache_size = 512;
    };
  };

  # Заставляем сервис ждать, пока сеть будет готова.
  systemd.services.dnscrypt-proxy2.after = [ "network-online.target" ];
  systemd.services.dnscrypt-proxy2.wants = [ "network-online.target" ];

  # Указываем системе использовать НАШ локальный DNS-прокси.
  networking.nameservers = [ "127.0.0.1" ];

  # Принудительно отключаем управление DNS через NetworkManager.
  networking.networkmanager.dns = lib.mkForce "none";

  # Правила файрвола остаются, они важны.
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
