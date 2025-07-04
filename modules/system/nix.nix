# modules/system/nix.nix
# Финальная, единственно правильная версия
{ pkgs, lib, ... }:

{
  # --- ИСТИННОЕ ЗАКЛИНАНИЕ ДЛЯ ОТКЛЮЧЕНИЯ IPV6 ---
  # Это канонический, документированный способ сказать всей системе
  # "прекратить использовать IPv6".
  networking.enableIPv6 = false;

  # --- ПРИКАЗЫ АРХИТЕКТОРУ-ДЕКОРАТОРУ (ОСТАЮТСЯ В СИЛЕ) ---
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # --- ПРИКАЗ ГЕНЕРАЛУ СЕТИ (ОСТАЮТСЯ В СИЛЕ) ---
  # Эти настройки все еще полезны для стабильности DNS.
  networking.networkmanager.dns = lib.mkForce "default";
  networking.nameservers = lib.mkForce [
    "1.1.1.1"  # Cloudflare DNS
    "8.8.8.8"  # Google DNS
    "9.9.9.9"  # Quad9 DNS
  ];
}
