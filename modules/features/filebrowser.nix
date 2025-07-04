# modules/features/filebrowser.nix
#
# Здесь мы строим последнюю, недостающую полку.
{ pkgs, ... }:

{
  # Эта часть правильная. Она создает папку для состояния.
  systemd.tmpfiles.rules = [
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

    # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
    # Эта опция говорит: "Я, контейнер filebrowser, хочу, чтобы для меня
    # была создана моя личная, временная директория в /run".
    runtimeDir = "filebrowser";
  };
}
