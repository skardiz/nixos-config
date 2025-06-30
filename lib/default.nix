# lib/default.nix
# Наша библиотека кастомных вспомогательных функций.
{ lib, ... }:

{
  myHelpers = {
    # --- Инструмент №1: Получение настроек Git ---
    # Эта функция принимает имя пользователя и возвращает его email и имя.
    getGitConfigForUser = userName:
      let
        # Вся наша "база данных" пользователей теперь живет здесь
        userMap = {
          alex = { userName = "Alex"; userEmail = "skardizone@gmail.com"; };
          # Если появится mari, ее можно будет добавить сюда
          # mari = { userName = "Mari"; userEmail = "mari@example.com"; };
        };
        # Настройки по умолчанию, если пользователь не найден
        defaultUser = { userName = "NixOS User"; userEmail = "user@localhost"; };
      in
      # Логика выбора: ищем в карте или возвращаем дефолт
      userMap.${userName} or defaultUser;


    # --- Инструмент №2: Генератор скрипта Waydroid ---
    # Эта функция принимает pkgs и генерирует наш скрипт-сторож.
    makeWaydroidIdleScript = { pkgs }:
      pkgs.writeShellScriptBin "waydroid-idle-manager" ''
        #!${pkgs.bash}/bin/bash
        TIMEOUT_SECONDS=300
        last_seen_timestamp=0
        are_waydroid_windows_open() {
          local window_ids=$(${pkgs.xorg.xwininfo}/bin/xwininfo -root -children | grep "^\s\+0x" | awk '{print $1}')
          for id in $window_ids; do
            if ${pkgs.xorg.xprop}/bin/xprop -id "$id" WM_CLASS | grep -q "waydroid"; then
              return 0
            fi
          done
          return 1
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
                sudo ${pkgs.systemd}/bin/systemctl stop waydroid-container.service
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
