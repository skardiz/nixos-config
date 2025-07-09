# outputs.nix
#
# Министерство Юстиции, которое уважает папку 'home'.
{ self, nixpkgs, home-manager, ... }@inputs:

let
  # Твоя существующая библиотека
  mylib = import ./lib { lib = nixpkgs.lib; pkgs = nixpkgs.legacyPackages."x86_64-linux"; };

  # Функция, которая находит все папки в директории 'hosts'
  # и считает их нашими Крепостями.
  discoverHosts = builtins.readDir ./hosts;

  # Собираем все конфигурации систем
  nixosSystems = builtins.listToAttrs (map (hostName: {
    name = hostName;
    value = let
      hostFlake = import ./hosts/${hostName}/flake.nix { inherit inputs; };
    in nixpkgs.lib.nixosSystem {
      system = hostFlake.system;
      specialArgs = { inherit inputs self mylib; };
      modules = hostFlake.modules;
    };
  }) (builtins.attrNames discoverHosts));

  # Собираем все конфигурации пользователей
  homeConfigurations = builtins.listToAttrs (builtins.concatLists (map (hostName: let
    hostFlake = import ./hosts/${hostName}/flake.nix { inherit inputs; };
  in map (userName: {
    name = "${userName}@${hostName}";
    value = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${hostFlake.system};
      extraSpecialArgs = { inherit inputs self mylib; };
      # --- ВОТ ОНО, ИСПРАВЛЕНИЕ С УВАЖЕНИЕМ ---
      # Мы смотрим в твою правильную папку 'home'.
      modules = [ ./home/${userName} ];
    };
  }) hostFlake.users) (builtins.attrNames discoverHosts)));

in
{
  # Отдаем финальный результат
  nixosConfigurations = nixosSystems;
  homeConfigurations = homeConfigurations;
}
