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

  outputs = { self, nixpkgs, ... }@inputs: {
    # Экспортируем наши оверлеи0
    overlays.default = import ./overlays;

    # Конфигурации системы----------------------------------
    nixosConfigurations = {
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [
          # Применяем оверлеи к системе
          { nixpkgs.overlays = [ self.overlays.default ]; }

          # Указываем на главную точку входа для хоста
          ./hosts/shershulya

          # Подключаем модуль Home Manager
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
