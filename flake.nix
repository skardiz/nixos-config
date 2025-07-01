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
    # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
    # Мы полностью удаляем блок plasma-manager.
    # plasma-manager = {
    #   url = "github:nix-community/plasma-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      mylib = import ./lib { lib = nixpkgs.lib; pkgs = nixpkgs.legacyPackages."x86_64-linux"; };
    in
    {
      nixosConfigurations = {
        shershulya = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self mylib; };
          modules = [
            # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
            # Мы полностью удаляем строку, которая импортировала оверлеи.
            # { nixpkgs.overlays = [ (import ./overlays) ]; }

            ./hosts/shershulya
            home-manager.nixosModules.home-manager
          ];
        };
      };

      homeConfigurations = {
        "alex@shershulya" = home-manager.lib.homeManagerConfiguration {
          # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
          # Мы больше не расширяем пакеты оверлеями.
          # Используем стандартный, чистый набор пакетов.
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/alex ];
        };
        "mari@shershulya" = home-manager.lib.homeManagerConfiguration {
          # И для второго пользователя тоже.
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/mari ];
        };
      };
    };
}

}
