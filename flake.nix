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
      # --- НОВЫЙ РАЗДЕЛ ЗДЕСЬ! ---
      # Импортируем нашу библиотеку и передаем ей стандартную библиотеку Nixpkgs,
      # чтобы мы могли использовать функции из нее внутри наших собственных функций.
      mylib = import ./lib { lib = nixpkgs.lib; };
    in
    {
      # --- РАЗДЕЛ 1: КОНФИГУРАЦИИ СИСТЕМ ---
      nixosConfigurations = {
        shershulya = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # Добавляем нашу библиотеку 'mylib' в specialArgs
          specialArgs = { inherit inputs self mylib; };

          modules = [
            # Подключаем наш хост
            ./hosts/shershulya

            # Подключаем Home Manager на уровне системы,
            # чтобы наш модуль users.nix мог им управлять.
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # --- РАЗДЕЛ 2: КОНФИГУРАЦИИ ПОЛЬЗОВАТЕЛЕЙ (HOME MANAGER) ---
      # Этот блок позволяет нам управлять конфигурациями пользователей отдельно.
      homeConfigurations = {
        "alex@shershulya" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          # Добавляем 'mylib' и сюда, чтобы использовать общие функции
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
