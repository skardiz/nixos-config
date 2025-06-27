# home/alex/bash.nix
{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyFile = ".config/bash/history";

    shellAliases = {
      # Псевдоним для публикации изменений на GitHub
      publish = "${pkgs.bash}/bin/bash /home/alex/nixos-config/scripts/publish.sh";

      ll = "ls -l";
      ls = "ls --color=tty";
      # и так далее...
    };
  };
}
