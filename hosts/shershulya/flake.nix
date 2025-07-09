# hosts/shershulya/flake.nix
#
# Местный закон для Крепости "shershulya"
{ inputs, ... }: {
  # Указываем, какую операционную систему мы строим
  system = "x86_64-linux";

  # Главное: перечисляем, кто из граждан живет в этой Крепости
  users = [ "alex" "mari" ];

  # Указываем, какие системные модули использовать для этой Крепости
  modules = [
    # Ссылаемся на твой существующий главный файл для этого хоста
    ./default.nix
    # И подключаем home-manager
    inputs.home-manager.nixosModules.home-manager
  ];
}
