# hm-modules/alex/packages.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    sops
    gnupg
    pinentry-curses
  ];
}
