# /home/alex/nixos-config/hm-modules/alex/default.nix
{ pkgs, config, ... }:

{
  imports = [
    ./git.nix
    ./firefox.nix
    ./plasma.nix
    ./bash.nix
    ./packages.nix
  ];
  # Убедись, что здесь нет ничего про hiddify-cli или systemd.user.services
}
