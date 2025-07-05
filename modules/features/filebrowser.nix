{ pkgs, ... }:
{
  systemd.tmpfiles.rules = [
    "d /run/filebrowser 0755 root root -"
    "d /var/lib/filebrowser 0755 root root -"
  ];
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ];
    volumes = [
      # --- ВОТ ОН, ЭКСПЕРИМЕНТ ---
      # Мы больше не смотрим на священную землю. Мы смотрим на нейтральную.
      "/tmp/test_share:/srv:z"
      "filebrowser-data:/config:z"
      "filebrowser-data:/database:z"
    ];
    cmd = [ "--port=8080", "--root=/srv" ];
  };
}
