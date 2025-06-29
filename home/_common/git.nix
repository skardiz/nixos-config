# home/_common/git.nix
{ config, ... }:

let
  # Создаем "карту" с персональными данными для каждого пользователя.
  # Это позволяет хранить все личные данные в одном месте.
  userSpecificSettings = {
    alex = {
      userName = "Alex";
      userEmail = "skardizone@gmail.com";
    };
    # Сюда легко добавить нового пользователя в будущем
    # guest = { ... };
  };

  # Получаем настройки для ТЕКУЩЕГО пользователя, для которого собирается конфиг.
  # Если пользователя нет в нашей карте, будет использован пустой набор {}.
  currentUserSettings = userSpecificSettings.${config.home.username} or {};

in
{
  # Включаем git и ssh-agent для всех
  programs.git.enable = true;
  services.ssh-agent.enable = true;

  # Применяем персональные настройки
  programs.git.userName = currentUserSettings.userName;
  programs.git.userEmail = currentUserSettings.userEmail;
}
