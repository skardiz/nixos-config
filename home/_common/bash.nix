# home/_common/bash.nix
{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyFile = ".config/bash/history";

    # Общие, полезные для всех алиасы
    shellAliases = {
      ll = "ls -l";
      ls = "ls --color=tty";
    };
  };
}
