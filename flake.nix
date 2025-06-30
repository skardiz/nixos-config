# flake.nix
{
  description = "Моя декларативная конфигурация NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Наша кастомная библиотека остается без изменений.
      mylib = import ./lib { lib = nixpkgs.lib; pkgs = nixpkgs.legacyPackages."x86_64-linux"; };
    in
    {
      # --- РАЗДЕЛ 1: КОНФИГУРАЦИИ СИСТЕМ ---
      nixosConfigurations = {
        shershulya = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self mylib; };

          modules = [
            # --- ГЛАВНАЯ МАГИЯ! ---
            # Мы указываем системе, что нужно использовать ВСЕ оверлеи
            # из нашей папки `overlays`. Это самый чистый и правильный способ.
            { nixpkgs.overlays = [ (import ./overlays) ]; }

            # Все остальные модули остаются без изменений.
            ./hosts/shershulya
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # --- РАЗДЕЛ 2: КОНФИГУРАЦИИ ПОЛЬЗОВАТЕЛЕЙ (HOME MANAGER) ---
      homeConfigurations = {
        "alex@shershulya" = home-manager.lib.homeManagerConfiguration {
          # Для Home Manager мы должны явно передать пакеты, которые уже
          # содержат наши оверлеи. Мы используем .extend для этого.
          pkgs = nixpkgs.legacyPackages."x86_64-linux".extend (import ./overlays);
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/alex ];
        };
        "mari@shershulya" = home-manager.lib.homeManagerConfiguration {
          # И для второго пользователя тоже.
          pkgs = nixpkgs.legacyPackages."x86_64-linux".extend (import ./overlays);
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/mari ];
        };
      };
    };
}
