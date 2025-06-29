# home/_common/bash.nix
{ config, ... }: # Убедитесь, что 'config' здесь есть

{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    # БЫЛО (вероятно):
    # historyFile = ".config/bash/history";

    # СТАЛО:
    # Указываем абсолютный путь к файлу истории в домашней директории пользователя.
    historyFile = "${config.home.homeDirectory}/.config/bash/history";

    # Общие, полезные для всех алиасы
    shellAliases = {
      ll = "ls -l";
      ls = "ls --color=tty";
    };
  };
}
