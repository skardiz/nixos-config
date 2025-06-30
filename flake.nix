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
      # Наша кастомная библиотека остается без изменений.
      mylib = import ./lib { lib = nixpkgs.lib; pkgs = nixpkgs.legacyPackages."x86_64-linux"; };

      # --- ИЗМЕНЕНИЕ №1: Определяем наш оверлей ---
      # Оверлей — это слой поверх стандартного набора пакетов Nixpkgs.
      # Мы используем его, чтобы добавить наш кастомный пакет `dpitunnel`.
      overlays = [
        (final: prev: {
          # Здесь мы говорим: "создай новый пакет 'dpitunnel',
          # используя рецепт из файла ./pkgs/dpitunnel".
          dpitunnel = prev.callPackage ./pkgs/dpitunnel { };
        })
      ];

      # --- ИЗМЕНЕНИЕ №2: Создаем кастомный набор пакетов для Home Manager ---
      # Standalone Home Manager конфигурации требуют явной передачи пакетов.
      # Мы создаем новый набор `pkgs`, который включает наши оверлеи.
      pkgsForHomeManager = import nixpkgs {
        system = "x86_64-linux";
        inherit overlays;
        config.allowUnfree = true; # Важно сохранить эту опцию
      };

    in
    {
      # --- РАЗДЕЛ 1: КОНФИГУРАЦИИ СИСТЕМ ---
      nixosConfigurations = {
        shershulya = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self mylib; };

          modules = [
            # --- ИЗМЕНЕНИЕ №3: Применяем оверлей к системе ---
            # Мы добавляем наш оверлей в список модулей.
            # Это самый чистый и правильный способ для NixOS.
            { nixpkgs.overlays = overlays; }

            # Все остальные модули остаются без изменений.
            ./hosts/shershulya
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # --- РАЗДЕЛ 2: КОНФИГУРАЦИИ ПОЛЬЗОВАТЕЛЕЙ (HOME MANAGER) ---
      homeConfigurations = {
        "alex@shershulya" = home-manager.lib.homeManagerConfiguration {
          # --- ИЗМЕНЕНИЕ №4: Используем наш кастомный `pkgs` ---
          # Вместо стандартного набора пакетов мы передаем тот,
          # который содержит наш `dpitunnel`.
          pkgs = pkgsForHomeManager;
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/alex ];
        };
        "mari@shershulya" = home-manager.lib.homeManagerConfiguration {
          # И для второго пользователя тоже.
          pkgs = pkgsForHomeManager;
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/mari ];
        };
      };
    };
}
