# modules/features/filebrowser.nix
#
# Здесь мы наносим Печать Прохода.
{ pkgs, ... }:

{
  # Эта часть была правильной.
  systemd.tmpfiles.rules = [
    "d /run/filebrowser 0755 root root -"
    "d /var/lib/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ];

    # --- ВОТ ОНО, ИСТИННОЕ ЗАКЛИНАНИЕ ---
    # Мы добавляем :z в конец нашего портала в сокровищницу.
    volumes = [
      "/home/alex/Загрузки:/srv:z"
      "filebrowser-data:/config"
      "filebrowser-data:/database"
    ];

    cmd = [ "--port=8080" ];
  };
}
