# home/_common/default.nix
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops,
    ./options.nix,
    ./git.nix,
    ./waydroid-idle.nix
  ];

  # Мы сообщаем личному sops-nix, где находится ключ.
  # Эта опция будет проигнорирована для Мари, так как у нее не будет
  # активирована ни одна опция, требующая sops.
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";
  my.home.packages.common = true;
}
