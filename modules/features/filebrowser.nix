# modules/features/filebrowser.nix
#
# Здесь мы приказываем NixOS создавать директорию для нашего сервиса.
{ pkgs, ... }:

{
  # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
  # Эта опция говорит: "Перед запуском системы убедись, что
  # директория /var/lib/filebrowser существует и принадлежит
  # правильному пользователю".
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0755 root root -"
  ];
  # --- КОНЕЦ ЛЕКАРСТВА ---

  # Остальная конфигурация контейнера остается без изменений. Она была правильной.
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    ports = [ "8088:80" ];
    volumes = [
      "/home/alex/Загрузки:/srv"
      # Теперь, когда директория /var/lib/filebrowser будет создана,
      # эти файлы смогут быть созданы внутри нее.
      "/var/lib/filebrowser/database.db:/database/filebrowser.db"
      "/var/lib/filebrowser/settings.json:/config/settings.json"
    ];
  };
}
