# home/_common/default.nix
{ pkgs, inputs, config, ... }:

{
  imports = [
    # --- ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЗДЕСЬ ---
    # Мы убираем все запятые из этого списка.
    inputs.sops-nix.homeManagerModules.sops
    ./options.nix
    ./git.nix
    ./waydroid-idle.nix
  ];

  # Пользовательский sops-nix теперь использует СВОЙ ЛИЧНЫЙ ключ из домашней директории.
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";
  my.home.packages.common = true;
}
