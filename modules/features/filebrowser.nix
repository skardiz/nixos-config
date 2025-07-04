# modules/features/filebrowser.nix
#
# Здесь мы исправляем ересь Лже-Императора, используя канонический путь.
{ pkgs, ... }:

{
  # Эта часть была правильной. Она создает необходимые временные папки.
  systemd.tmpfiles.rules = [
    "d /run/filebrowser 0755 root root -"
    "d /var/lib/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ];

    # --- ВОТ ОН, ИСТИННЫЙ ЗАКОН ---
    # Мы убираем еретическую секцию 'virtualisation.oci-containers.volumes'.
    # Мы просто используем имя 'filebrowser-data' как источник.
    # Podman сам поймет, что это именованный том, и создаст его.
    volumes = [
      "/home/alex/Загрузки:/srv"
      "filebrowser-data:/config"
      "filebrowser-data:/database"
    ];

    cmd = [
      "--port=8080"
      "--no-healthcheck" # <-- Оставляем это, так как проблема с healthcheck была реальной.
    ];
  };
}
