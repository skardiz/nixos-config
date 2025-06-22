{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    telegram-desktop
    obsidian
  ];

  # Мы удалили отсюда `programs.git.enable = true;`,
  # так как Git теперь является персональной настройкой.
}
