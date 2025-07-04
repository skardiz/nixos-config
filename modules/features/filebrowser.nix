# modules/features/filebrowser.nix
#
# Здесь мы следуем истинному, каноническому пути.
{ pkgs, ... }:

{
  # --- Шаг 1: Мы убираем ересь о 'tmpfiles.d' ---
  # systemd.tmpfiles.rules = [ ... ];

  # --- Шаг 2: Мы объявляем суверенную территорию ---
  # Мы создаем именованный том, которым будет управлять сам Podman.
  virtualisation.oci-containers.volumes."filebrowser-data" = {};

  # --- Шаг 3: Мы даем Посольству доступ к этой территории ---
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ];
    volumes = [
      "/home/alex/Загрузки:/srv"
      # Мы говорим: "Соедини наш новый том 'filebrowser-data'
      # с внутренними папками контейнера".
      "filebrowser-data:/config"
      "filebrowser-data:/database"
    ];
    cmd = [ "--port=8080" ];
  };
}
