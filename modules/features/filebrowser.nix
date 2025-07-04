# modules/features/filebrowser.nix
#
# Здесь мы изгоняем демона привилегированных портов.
{ pkgs, ... }:

{
  # Эта часть правильная. Она создает папку для состояния.
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0755 root root -"
  ];

  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser:latest";
    # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
    # Мы говорим: "Снаружи пусть будет порт 8088, а внутри контейнера
    # пусть он слушает порт 8080". 8080 - это обычный, непривилегированный порт.
    ports = [ "8088:8080" ];
    volumes = [
      "/home/alex/Загрузки:/srv"
      "/var/lib/filebrowser:/config"
      "/var/lib/filebrowser:/database"
    ];
    # Мы должны явно сказать приложению использовать новый порт
    command = [ "--port=8080" ];
  };
}
