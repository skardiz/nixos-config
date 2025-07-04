# modules/features/filebrowser.nix
#
# Здесь мы отменяем указ Лже-Императора.
{ pkgs, ... }:

{
  # Эта часть правильная. Она создает папку для состояния.
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0755 root root -"
    "d /run/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:8080" ];
    volumes = [
      "/home/alex/Загрузки:/srv"
      "/var/lib/filebrowser:/config"
      "/var/lib/filebrowser:/database"
    ];

    # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
    # Мы просто указываем порт. Больше ничего не нужно.
    # --no-healthcheck было моей ошибкой.
    cmd = [
      "--port=8080"
    ];
  };
}
