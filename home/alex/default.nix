# home/alex/default.nix
{ pkgs, config, ... }:
{
  imports = [
    ../_common
    ./packages.nix
  ];

  my.home.packages.dev = true;

  # --- НАЖИМАЕМ КНОПКУ ---
  my.home.enableUserSshKey = true;
}
