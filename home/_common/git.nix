# home/_common/git.nix
# Этот модуль теперь использует хелпер из нашей кастомной библиотеки.
{ config, pkgs, mylib, ... }: # <-- Добавляем 'mylib' в аргументы

let
  # Вызываем наш новый, чистый хелпер из библиотеки.
  # Передаем ему имя текущего пользователя.
  gitSettings = mylib.myHelpers.getGitConfigForUser config.home.username;
in
{
  programs.git = {
    enable = true;
    # Применяем результат работы хелпера
    userName = gitSettings.userName;
    userEmail = gitSettings.userEmail;
  };
  services.ssh-agent.enable = true;
}
