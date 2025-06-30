# home/alex/default.nix
{ pkgs, config, ... }:
{
  imports = [
    ../_common # Импортируем ВСЕ общие настройки

    # Персональные модули Алекса
    ./packages.nix
  ];
}
