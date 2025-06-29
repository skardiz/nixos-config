# home/_common/git.nix
{ config, pkgs, ... }:

let
  # Создаем "карту" с персональными данными для каждого пользователя.
  userSpecificSettings = {
    alex = {
      userName = "Alex";
      userEmail = "skardizone@gmail.com";
    };
  };

  # ------------------------------------------------------------------
  # ИЗМЕНЕНИЕ ЗДЕСЬ: Добавляем 'or { ... }' для обработки неизвестных пользователей
  # ------------------------------------------------------------------
  # Получаем настройки для ТЕКУЩЕГО пользователя.
  # Если пользователя нет в нашей карте (например, root),
  # будет использован набор атрибутов по умолчанию.
  currentUserSettings = userSpecificSettings.${config.home.username} or {
    userName = "NixOS User";
    userEmail = "user@localhost";
  };

in
{
  # Включаем git и ssh-agent для всех
  programs.git.enable = true;
  services.ssh-agent.enable = true;

  # Применяем персональные или дефолтные настройки
  # Теперь эти строки всегда будут работать, так как currentUserSettings никогда не будет пустым.
  programs.git.userName = currentUserSettings.userName;
  programs.git.userEmail = currentUserSettings.userEmail;
}
