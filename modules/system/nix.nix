# modules/system/nix.nix
# Общие настройки для Nix, которые будут применяться ко всем хостам.
{ pkgs, ... }:

{
  # Эта опция говорит NixOS: "Возьми все настройки из блока nix.settings
  # и сделай их глобальными, записав в /etc/nix/nix.conf".
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Здесь мы определяем сами настройки.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://nix-community.cachix.org" ];
  };
}
