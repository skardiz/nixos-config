# flake.nix
{
  description = "Моя декларативная конфигурация NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # --- НОВАЯ СТРОКА ЗДЕСЬ! ---
    # Добавляем репозиторий с настройками для железа
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

  # Мы должны также добавить 'hardware' в аргументы функции outputs
  outputs = { self, nixpkgs, home-manager, hardware, ... }@inputs: {
    nixosConfigurations = {
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # specialArgs уже передает все inputs, так что здесь ничего менять не нужно
        specialArgs = { inherit inputs self; };

        modules = [
          ./hosts/shershulya
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
