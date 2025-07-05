# modules/features/filebrowser.nix
#
# Здесь мы исправляем грамматическую ошибку самозванца.
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
      "/tmp/test_share:/srv:z"
      "filebrowser-data:/config:z"
      "filebrowser-data:/database:z"
    ];

    # --- ВОТ ОНО, ИСТИННОЕ НАПИСАНИЕ ---
    # Мы убираем проклятую запятую.
    cmd = [
      "--port=8080"
      "--root=/srv"
    ];
  };
}
