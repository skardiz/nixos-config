# /etc/nixos/flake.nix
{
  description = "Моя чистая, модульная система на стандартном ядре";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # chaotic.url = "github:chaotic-cx/nyx"; # УДАЛЕНО
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Убираем 'chaotic' из аргументов функции
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          # --- Фундамент системы ---
          ./hardware-configuration.nix

          # --- Наши системные модули ---
          ./modules/system.nix
          ./modules/users.nix
          ./modules/desktop.nix
          ./modules/nvidia.nix
          ./modules/gaming.nix
          ./modules/services.nix
          # ./modules/zfs-btrfs.nix # Мы его уже удалили

          # --- Системный модуль для интеграции Home Manager ---
          home-manager.nixosModules.home-manager

          # --- Оверлей для ядра CachyOS ---
          # chaotic.nixosModules.default # УДАЛЕНО
        ];
      };
    };
  };
}
