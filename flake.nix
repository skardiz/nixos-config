# flake.nix
{
  description = "Моя финальная, чистая система на стандартном ядре";

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

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs: {
    nixosConfigurations = {
      # --- Конфигурация для хоста shershulya ---
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [
          # Главная точка входа для хоста. Nix автоматически найдет default.nix
          ./hosts/shershulya

          # Подключаем модуль Home Manager. Это включает интеграцию с NixOS.
          home-manager.nixosModules.home-manager
        ];
      };

      # Если в будущем появится другой хост, вы просто добавите его сюда:
      # another-host = nixpkgs.lib.nixosSystem { ... };
    };
  };
}
