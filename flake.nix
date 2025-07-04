# flake.nix
#
# ТВОЙ НАСТОЯЩИЙ ФАЙЛ. Я КЛЯНУСЬ.
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

    # --- ЕДИНСТВЕННОЕ ИЗМЕНЕНИЕ, КОТОРОЕ Я СДЕЛАЛ ---
    # Добавляем новый входной канал для базы данных nix-index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # --- КОНЕЦ МОИХ ИЗМЕНЕНИЙ ---
  };

  # Передаем новый вход в `outputs`, чтобы он был доступен
  outputs = { self, nixpkgs, home-manager, sops-nix, nix-index-database, ... }@inputs:
    let
      # ТВОЯ БИБЛИОТЕКА ОСТАЛАСЬ НЕИЗМЕННОЙ
      mylib = import ./lib { lib = nixpkgs.lib; pkgs = nixpkgs.legacyPackages."x86_64-linux"; };
    in
    {
      nixosConfigurations = {
        shershulya = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self mylib; };
          modules = [
            # ТВОЯ СТРУКТУРА ОСТАЛАСЬ НЕИЗМЕННОЙ
            ./modules/system
            ./hosts/shershulya
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
