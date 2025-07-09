# home/_common/default.nix
{ pkgs, inputs, config, ... }: # Убедитесь, что 'config' здесь есть

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./options.nix
    ./git.nix
    ./waydroid-idle.nix
  ];

  # --- ФИНАЛЬНОЕ РЕШЕНИЕ ---
  # Мы говорим sops-nix использовать ключ, который лежит в вашей домашней директории.
  # Прямо. Просто. Без копирования. Без костылей.
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # Мы также указываем, где лежат сами зашифрованные секреты.
  sops.defaultSopsFile = ../../secrets.yaml;

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";
  my.home.packages.common = true;
}
