# modules/system/nix.nix
# Общие настройки для Nix, которые будут применяться ко всем хостам.
{ pkgs, ... }:

{
  # Эта опция говорит NixOS: "Возьми все настройки из блока nix.settings
  # и сделай их глобальными, записав в /etc/nix/nix.conf".
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Здесь мы определяем сами настройки.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    # --- ВОТ ОН, ПРАВИЛЬНЫЙ КЛЮЧ, КОТОРЫЙ МЫ ВЫСТРАДАЛИ ---
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
