# modules/features/vpn.nix

# Финальная, рабочая конфигурация для AmneziaWG,
# которая уважает магию sops-nix.
{ config, pkgs, ... }:

{
  # 1. Мы предполагаем, что в твоем главном файле (например, hosts/shershulya/default.nix)
  # уже есть что-то вроде этого. Убедись, что владелец - root, так как сервис системный.
  #
  # sops.secrets.vpn_private_key = {
  #   sopsFile = ../../secrets/secrets.yaml;
  #   owner = "root";
  # };
  #
  # ВАЖНО: 'vpn_private_key' - это имя секрета в secrets.yaml. Если у тебя он
  # называется иначе (например, 'amnezia_key'), измени его здесь и ниже.

  # 2. Утилиты (остаются без изменений)
  boot.extraModulePackages = [ pkgs.linuxKernel.packages.linux_zen.amneziawg ];
  environment.systemPackages = with pkgs; [
    amnezia-vpn
    amneziawg-tools
    amneziawg-go
  ];

  # 3. Мы больше не создаем файл в /etc. Мы создадим его на лету.

  # 4. Надежный сервис systemd, который умеет читать секреты
  systemd.services.amnezia-vpn = {
    description = "AmneziaWG auto-connect service";
    after = [ "network-online.target" "sops-nix.service" ]; # Ждем, пока сейфы откроются
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    # Этот скрипт будет исполняться при каждом запуске сервиса
    script = ''
      # Путь к нашему временному, секретному конфигу
      CONF_FILE="/run/amnezia-vpn/awg0.conf"

      # Создаем папку для него
      mkdir -p "$(dirname "$CONF_FILE")"

      # Читаем секретный ключ из файла, который создала sops
      PRIVATE_KEY=$(cat "${config.sops.secrets.vpn_private_key.path}")

      # Собираем финальный конфиг, подставляя ключ
      cat > "$CONF_FILE" << EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.8.0.4/24
DNS = 1.1.1.1
Jc = 9
Jmin = 50
Jmax = 1000
S1 = 100
S2 = 75
H1 = 1583110509
H2 = 1884699694
H3 = 538034460
H4 = 1051564253

[Peer]
PublicKey = wNeK1oGyI7fVtLMI4lzFKllowEvuw72VV/F4k/uX9xk=
PresharedKey = PFLFbHnr1Wuctm6JuSukg73/xxHohmNZ3IPsYvKpImY=
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 0
Endpoint = 185.125.200.148:51820
EOF

      # Запускаем туннель, используя наш свежесозданный конфиг
      ${pkgs.amneziawg-tools}/bin/awg-quick up "$CONF_FILE"
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0";
    };
  };
}
