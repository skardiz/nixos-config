# home/_common/default.nix
{ pkgs, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./options.nix
    ./git.nix
    ./waydroid-idle.nix
  ];

  # Мы просто сообщаем личному sops-nix, где находится тот же самый системный ключ.
  # Так как пользователь 'alex' в группе 'sops', у него будут права на чтение.
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";
  my.home.packages.common = true;
}
