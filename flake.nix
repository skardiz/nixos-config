# flake.nix
{
  description = "Моя декларативная конфигурация NixOS";

  inputs = { /* ... без изменений ... */ };

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
            # --- ГЛАВНАЯ МАГИЯ! ---
            # Мы указываем системе, что нужно использовать
            # ВСЕ оверлеи из нашей папки `overlays`.
            { nixpkgs.overlays = [ (import ./overlays) ]; }

            # Все остальные модули остаются без изменений.
            ./hosts/shershulya
            home-manager.nixosModules.home-manager
          ];
        };
      };

      homeConfigurations = {
        "alex@shershulya" = home-manager.lib.homeManagerConfiguration {
          # Для Home Manager мы должны передать пакеты, которые уже
          # содержат наши оверлеи.
          pkgs = nixpkgs.legacyPackages."x86_64-linux".extend (import ./overlays);
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/alex ];
        };
        "mari@shershulya" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux".extend (import ./overlays);
          extraSpecialArgs = { inherit inputs self mylib; };
          modules = [ ./home/mari ];
        };
      };
    };
}
