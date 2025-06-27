# home/alex/bash.nix
{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyFile = ".config/bash/history";

    shellAliases = {
      # Псевдоним для публикации изменений на GitHub
      publish = ''/home/alex/nixos-config/scripts/publish.sh'';

      # Пример других полезных алиасов
      ll = "ls -l";
      ls = "ls --color=tty";
    };
  };
}
