# modules/features/docker.nix
#
# Эта фича отвечает за включение и настройку Docker.
{ lib, config, ... }:

{
  # Включаем сам Docker
  virtualisation.docker.enable = true;

  # Даем всем пользователям, определенным в нашей системе,
  # доступ к сокету Docker. Это элегантный способ, не требующий
  # ручного добавления каждого пользователя.
  users.extraGroups.docker.members = lib.mapAttrsToList (name: value: name) config.my.users.accounts;

  # Раскомментируй следующую строку, если твоя файловая система - BTRFS
  virtualisation.docker.storageDriver = "btrfs";
}
