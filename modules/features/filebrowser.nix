# modules/features/filebrowser.nix
#
# Это — последняя надежда. Мы меняем контракт.
{ pkgs, ... }:

{
  # Эта часть остается. Она правильная.
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:80" ];
    volumes = [
      "/home/alex/Загрузки:/srv"

      # --- ВОТ ОНО, ИЗМЕНЕНИЕ КОНТРАКТА ---
      # Мы больше не указываем файлы. Мы даем контейнеру целые папки,
      # чтобы он сам управлял тем, что внутри.
      "/var/lib/filebrowser:/config"
      "/var/lib/filebrowser:/database" # <-- Да, обе папки контейнера
                                       # будут смотреть в одну нашу.
                                       # Это стандартная практика.
    ];
  };
}
