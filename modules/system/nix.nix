# modules/system/nix.nix
# Финальная, единственно правильная версия
{ pkgs, lib, ... }:

{

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

}
