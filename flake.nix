{
  description = "Моя финальная, чистая система на стандартном ядре";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          ./modules/system.nix
          ./modules/users.nix
          ./modules/desktop.nix
          ./modules/nvidia.nix
          ./modules/gaming.nix
          ./modules/services.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
