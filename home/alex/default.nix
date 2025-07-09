# home/alex/default.nix
{ pkgs, config, ... }:

{ # <--- Эта открывающая скобка была пропущена
  imports = [
    ../_common
    ./packages.nix
  ];

  my.home.packages.dev = true;

  my.home.enableUserSshKey = true;
} # <--- Эта закрывающая скобка была пропущена
