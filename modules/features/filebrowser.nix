# modules/features/filebrowser.nix
#
# Здесь мы ставим крест на карте.
{ pkgs, ... }:

{
  # Эта часть правильная.
  systemd.tmpfiles.rules = [
    "d /run/filebrowser 0755 root root -"
    "d /var/lib/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ];
    volumes = [
      "/home/alex/Загрузки:/srv:z" # Печать Прохода оставляем, она не мешает.
      "filebrowser-data:/config:z"
      "filebrowser-data:/database:z"
    ];

    # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
    # Мы явно приказываем приложению считать своей корневой папкой /srv.
    cmd = [
      "--port=8080"
      "--root=/srv"
    ];
  };
}
