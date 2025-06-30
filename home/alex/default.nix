# home/alex/default.nix
{ pkgs, config, ... }:
{
  imports = [
    ../_common # Импортируем ВСЕ общие настройки
    ./packages.nix
  ];

  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
  # Алекс включает себе дополнительный набор пакетов для разработки
  my.home.packages = {
    dev = true;
  };
}
