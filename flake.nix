# flake.nix (НОВАЯ, ЧИСТАЯ ВЕРСИЯ)
{
  description = "Моя декларативная Империя";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Мы выносим всю логику в отдельный файл, чтобы здесь была чистота
  outputs = inputs: import ./outputs.nix inputs;
}
