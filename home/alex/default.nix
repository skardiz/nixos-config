# home/alex/default.nix
{ pkgs, config, ... }:

# --- НАЧАЛО ВОЗВРАЩАЕМОГО НАБОРА ---
{
  imports = [
    ../_common
    ./packages.nix
  ];

  my.home.packages.dev = true;

  # --- НАЖИМАЕМ КНОПКУ ---
  my.home.enableUserSshKey = true;
}
# --- КОНЕЦ ВОЗВРАЩАЕМОГО НАБОРА ---
