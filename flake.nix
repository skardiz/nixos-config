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
    # --- Экспортируем наши оверлеи (это было сделано ранее и это правильно) ---
    overlays.default = import ./overlays;

    # --- Конфигурации системы ---
    nixosConfigurations = {
      shershulya = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [
          # --- ВАЖНО: Применяем оверлеи к системе ---
          # Эта строка говорит nixpkgs использовать наш оверлей.
          # Теперь `pkgs` для всей системы будет содержать наши кастомные пакеты.
          { nixpkgs.overlays = [ self.overlays.default ]; }

          # Указываем на главную точку входа для хоста.
          ./hosts/shershulya

          # Подключаем модуль Home Manager.
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
