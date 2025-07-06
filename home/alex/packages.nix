# hm-modules/alex/packages.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bash
    sops
    gnupg
    pinentry-curses
    anydesk
    #thorium-browser
  ];
}
