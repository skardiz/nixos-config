# modules/features/filebrowser.nix
#
# Мы больше не используем 'docker run'. Мы приказываем NixOS
# самой управлять этим контейнером.
{ pkgs, ... }:

{
  # Включаем нативный для NixOS запуск OCI/Docker контейнеров
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:80" ];
    volumes = [
      # Мы жестко прописываем путь, как мы уже научились
      "/home/alex/Загрузки:/srv"
      # Базу данных и конфиг мы тоже прописываем, но без Docker-папок
      "/var/lib/filebrowser/database.db:/database/filebrowser.db"
      "/var/lib/filebrowser/settings.json:/config/settings.json"
    ];
    # ВАЖНО: Мы не указываем пользователя! NixOS сама разберется
    # с правами, запуская это как системный сервис.
  };
}
