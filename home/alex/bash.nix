# home/alex/bash.nix
{ pkgs, ... }:
{
  programs.bash.shellAliases = {
    # Псевдоним для публикации изменений на GitHub
    publish = "${pkgs.bash}/bin/bash /home/alex/nixos-config/scripts/publish.sh";
  };
}

