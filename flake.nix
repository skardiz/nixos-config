{
  description = "Моя финальная, чистая система на стандартном ядре";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # --- НОВАЯ ЗАВИСИМОСТЬ ---0
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs: {
    nixosConfigurations = {
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # --- ПЕРЕДАЕМ ЗАВИСИМОСТЬ В МОДУЛИ ----
        specialArgs = { inherit inputs self; };
        modules = [
          ./hardware-configuration.nix
          ./modules/system.nix
          ./modules/users.nix
          ./modules/desktop.nix
          ./modules/nvidia.nix
          ./modules/gaming.nix
          ./modules/services.nix
          ./modules/hearthstone.nix
          ./modules/amnezia.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
