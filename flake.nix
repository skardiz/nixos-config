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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let
      mylib = import ./lib { lib = nixpkgs.lib; pkgs = nixpkgs.legacyPackages."x86_64-linux"; };
    in
    {
      nixosConfigurations = {
        shershulya = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self mylib; };
          modules = [
            # --- ГЛАВНОЕ ИЗМЕНЕНИЕ ---
            # 1. Импортируем наш новый центральный модуль для всех хостов
            ./modules/system
            # 2. Импортируем конфигурацию конкретного хоста
            ./hosts/shershulya
            # 3. Импортируем Home Manager, так как он тоже общий
            home-manager.nixosModules.home-manager
          ];
        };
      };
      homeConfigurations = {
        "alex@shershulya" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/alex ];
        };
        "mari@shershulya" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/mari ];
        };
      };
    };
}
