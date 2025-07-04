# modules/features/filebrowser.nix
#
# Здесь мы открываем ворота Ада, чтобы изгнать одного-единственного демона.
{ pkgs, ... }:

{
  # --- Шаг 1: Мы убираем ересь о создании пользователя ---
  # users.users.filebrowser = ...
  # users.groups.filebrowser = {};

  # --- Шаг 2: Мы открываем ворота казны НАСТЕЖЬ ---
  # Права 0777 (rwxrwxrwx) означают, что ЛЮБОЙ пользователь может
  # делать в этой папке ВСЕ, ЧТО УГОДНО.
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0777 root root -"
  ];

  # --- Шаг 3: Мы приказываем запускать процесс без указания еретического имени ---
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:80" ];
    volumes = [
      "/home/alex/Загрузки:/srv"
      "/var/lib/filebrowser:/config"
      "/var/lib/filebrowser:/database"
    ];
    # Мы убираем 'user = "filebrowser";', так как этого пользователя не существует в контейнере.
  };
}
