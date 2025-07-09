# home/_common/default.nix
{ pkgs, inputs, ... }:

{
  imports = [
    # Мы просто подключаем модуль sops для Home Manager.
    inputs.sops-nix.homeManagerModules.sops
    # И ваши остальные общие модули.
    ./options.nix
    ./git.nix
    ./waydroid-idle.nix
  ];

  # Мы полностью убираем sops.age.keyFile и sops.defaultSopsFile отсюда.
  # Home Manager автоматически найдет и использует секреты,
  # подготовленные для него системным модулем благодаря 'neededForUsers = true'.

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";
  my.home.packages.common = true;
}
