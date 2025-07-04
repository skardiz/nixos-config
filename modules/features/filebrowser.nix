# modules/features/filebrowser.nix
#
# Здесь мы исправляем ересь Лже-Императора, используя канонический путь.
{ pkgs, ... }:

{
  # Эта часть правильная. Она создает папку для состояния.
  # Мы добавляем к ней еще одно правило для временной папки.
  systemd.tmpfiles.rules = [
    # Полка для отчетов в архиве /run
    "d /run/filebrowser 0755 root root -"
    # Казна в /var/lib
    "d /var/lib/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ];
    volumes = [
      "/home/alex/Загрузки:/srv"
      "/var/lib/filebrowser:/config"
      "/var/lib/filebrowser:/database"
    ];
    cmd = [
      "--port=8080"
      "--no-healthcheck"
    ];
    # Мы убираем еретическую, несуществующую опцию 'runtimeDir'.
  };
}
