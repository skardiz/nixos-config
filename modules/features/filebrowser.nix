# modules/features/filebrowser.nix
#
# Здесь мы изгоняем последнего призрака.
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
    cmd = [ "--port=8080" ];

    # --- ИМПЕРАТОРСКИЙ УКАЗ: ИЗГНАТЬ ПРИЗРАКА! ---
    # Мы явно отключаем автоматическую проверку здоровья.
    # Нам не нужна паникующая медсестра.
    healthcheck.enable = false;
  };
}
