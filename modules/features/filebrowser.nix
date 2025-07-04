# modules/features/filebrowser.nix
#
# Здесь мы изгоняем демона "Permission Denied" раз и навсегда.
{ pkgs, ... }:

{
  # --- Шаг 1: Создаем официальную должность "Казначея" ---
  # Мы создаем системного пользователя и группу с именем 'filebrowser'.
  users.users.filebrowser = {
    isSystemUser = true;
    group = "filebrowser";
  };
  users.groups.filebrowser = {};

  # --- Шаг 2: Отдаем казну Казначею ---
  # Теперь мы создаем директорию и сразу говорим, что она
  # принадлежит нашему новому пользователю 'filebrowser'.
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0755 filebrowser filebrowser -"
  ];

  # --- Шаг 3: Назначаем Казначея на работу ---
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:80" ];
    volumes = [
      "/home/alex/Загрузки:/srv"
      "/var/lib/filebrowser:/config"
      "/var/lib/filebrowser:/database"
    ];
    # Мы явно приказываем запускать процесс от имени нашего
    # нового, доверенного пользователя.
    user = "filebrowser";
  };
}
