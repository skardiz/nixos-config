# home/_common/default.nix
{ pkgs, inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops,
    ./options.nix,
    ./git.nix,
    ./waydroid-idle.nix
  ];

  # --- ВОТ ОНО, ФИНАЛЬНОЕ РЕШЕНИЕ ---
  # Мы явно и прямо сообщаем личному sops-nix, где находится тот же самый системный ключ.
  # Это устраняет ошибку "No key source configured".
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  # Указывать defaultSopsFile здесь не нужно, home-manager его унаследует.

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";
  my.home.packages.common = true;
}
