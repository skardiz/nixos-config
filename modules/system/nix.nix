# modules/system/nix.nix
# Общие настройки для Nix, которые будут применяться ко всем хостам,
# включая стабилизацию сети с высшим приоритетом.
{ pkgs, lib, ... }: # <-- Убедись, что 'lib' здесь есть

{
  # --- СТАРЫЕ, ПРАВИЛЬНЫЕ НАСТРОЙКИ NIX ---
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

  # --- НОВЫЙ, УСИЛЕННЫЙ БЛОК ДЛЯ СЕТИ ---
  # С помощью `lib.mkForce` мы отдаем приказ с высшим приоритетом,
  # отменяя любые конфликтующие настройки по умолчанию.
  networking.networkmanager.dns = lib.mkForce "default";
  networking.nameservers = lib.mkForce [
    "1.1.1.1"  # Cloudflare DNS
    "8.8.8.8"  # Google DNS
    "9.9.9.9"  # Quad9 DNS (еще один для надежности)
  ];
}
