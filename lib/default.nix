# lib/default.nix
# Наша библиотека кастомных вспомогательных функций.
{ lib, pkgs, ... }:

{
  myHelpers = {
    # --- Инструмент №1: Получение настроек Git (без изменений) ---
    getGitConfigForUser = userName:
      let
        userMap = {
          alex = { userName = "Alex"; userEmail = "skardizone@gmail.com"; };
        };
        defaultUser = { userName = "NixOS User"; userEmail = "user@localhost"; };
      in
      userMap.${userName} or defaultUser;

    # --- Инструмент №2: Генератор скрипта Waydroid (Улучшенный) ---
    makeWaydroidIdleScript = { pkgs }:
      pkgs.writeShellScriptBin "waydroid-idle-manager" ''
        #!${pkgs.bash}/bin/bash
        TIMEOUT_SECONDS=300
        last_seen_timestamp=0

        # Функция для проверки, открыты ли окна Waydroid
        are_waydroid_windows_open() {
          local window_ids=$(${pkgs.xorg.xwininfo}/bin/xwininfo -root -children | grep "^\s\+0x" | awk '{print $1}')
          for id in $window_ids; do
            if ${pkgs.xorg.xprop}/bin/xprop -id "$id" WM_CLASS | grep -q "waydroid"; then
              return 0 # 0 означает "да, открыты"
            fi
          done
          return 1 # 1 означает "нет, не открыты"
        }

        echo "WayDroid Idle Manager запущен для пользователя $USER."
        while true; do
          if are_waydroid_windows_open; then
            last_seen_timestamp=$(date +%s)
          else
            if [[ $last_seen_timestamp -ne 0 ]]; then
              current_time=$(date +%s)
              elapsed=$((current_time - last_seen_timestamp))
              if [[ $elapsed -gt $TIMEOUT_SECONDS ]]; then
                echo "Таймаут ($TIMEOUT_SECONDS сек) достигнут. Остановка WayDroid..."
                ${pkgs.waydroid}/bin/waydroid session stop
                # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
                # Вместо 'sudo systemctl stop ...' мы отправляем сообщение по D-Bus.
                ${pkgs.glib}/bin/gdbus call --system --dest org.waydroid.container \
                  --object-path /org/freedesktop/systemd1 \
                  --method org.freedesktop.systemd1.Manager.StopUnit "waydroid-container.service" "replace"
                echo "WayDroid остановлен."
                last_seen_timestamp=0
              fi
            fi
          fi
          sleep 10
        done
      '';
  };
}
