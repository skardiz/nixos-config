# modules/features/filebrowser.nix
#
# Здесь мы исправляем указ Лже-Императора.
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

    # --- ВОТ ОН, ИСТИННЫЙ ЗАКОН ---
    # Мы добавляем еще один аргумент в команду запуска контейнера.
    # `--no-healthcheck` - это стандартный флаг для filebrowser,
    # который говорит ему не запускать внутреннюю проверку здоровья.
    cmd = [
      "--port=8080"
      "--no-healthcheck"
    ];
  };
}
