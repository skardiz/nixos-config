# modules/features/filebrowser.nix
#
# Здесь мы исправляем ошибку самозванца.
{ pkgs, ... }:

{
  # Эта часть правильная. Она создает папку для состояния.
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ]; # Это было правильное решение
    volumes = [
      "/home/alex/Загрузки:/srv"
      "/var/lib/filebrowser:/config"
      "/var/lib/filebrowser:/database"
    ];

    # --- ВОТ ОНО, ИСТИННОЕ СЛОВО ---
    # Не 'command', а 'cmd'. Это - аргументы, которые передаются
    # после точки входа (entrypoint) контейнера.
    cmd = [ "--port=8080" ];
  };
}
