# modules/system/nix.nix
# Финальная, единственно правильная версия
{ pkgs, lib, ... }:

{
  # --- ПРИКАЗ ГЛАВНОМУ АРХИТЕКТОРУ ---
  # Эта опция напрямую говорит демону Nix отключить IPv6.
  # Это не часть nix.settings, это глобальная настройка.
  nix.net.ipv6 = false;

  # --- ПРИКАЗЫ АРХИТЕКТОРУ-ДЕКОРАТОРУ ---
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

  # --- ПРИКАЗ ГЕНЕРАЛУ СЕТИ ---
  # Эти настройки остаются, они полезны для общей стабильности системы.
  networking.networkmanager.dns = lib.mkForce "default";
  networking.nameservers = lib.mkForce [
    "1.1.1.1"  # Cloudflare DNS
    "8.8.8.8"  # Google DNS
    "9.9.9.9"  # Quad9 DNS
  ];
}
