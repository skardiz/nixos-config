# flake.nix
{
  description = "Моя декларативная конфигурация NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Мы передаем 'self' (GPS-трекер на корень проекта)
        # и 'inputs' во все системные модули.
        specialArgs = { inherit inputs self; };

        modules = [
          # Подключаем наш хост
          ./hosts/shershulya

          # Подключаем Home Manager на уровне системы
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
