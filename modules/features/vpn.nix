# modules/features/vpn.nix

# Финальный, рабочий указ, исправленный мудростью Императора.
{ config, pkgs, ... }:

{
  # --- Шаг 1: Сборка модуля (остается) ---
  # Этот указ, как вы и сказали, был верным.
  boot.extraModulePackages = [ config.boot.kernelPackages.amneziawg ];

  # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
  # Этот указ говорит: "Не просто построй эту деталь.
  # ЯВНО ВКРУТИ ее в двигатель при каждом запуске Королевства!".
  boot.kernelModules = [ "amneziawg" ];

  # ... остальная часть файла (утилиты, сервис, sops) остается без изменений ...
  environment.systemPackages = with pkgs; [
    amnezia-vpn
    amneziawg-tools
    amneziawg-go
  ];

  # Если ты используешь sops, эта секция должна быть в твоем главном конфиге,
  # а не здесь. Я лишь напоминаю о ее структуре.
  # sops.secrets.vpn_private_key.owner = "root";

  systemd.services.amnezia-vpn = {
    description = "AmneziaWG auto-connect service";
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      CONF_FILE="/run/amnezia-vpn/awg0.conf"
      mkdir -p "$(dirname "$CONF_FILE")"
      chmod 700 "$(dirname "$CONF_FILE")" # Защищаем папку
      PRIVATE_KEY=$(cat "${config.sops.secrets.vpn_private_key.path}")

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

      chmod 600 "$CONF_FILE" # Защищаем сам конфиг

      ${pkgs.amneziawg-tools}/bin/awg-quick up "$CONF_FILE"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0";
    };
  };
}
