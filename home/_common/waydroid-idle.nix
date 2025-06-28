# home/_common/waydroid-idle.nix
#
# Этот модуль создает и управляет сервисом-сторожем для WayDroid.
# Он автоматически останавливает WayDroid после 5 минут бездействия.
{ pkgs, ... }:

let
  # Создаем скрипт-сторож с помощью функции Nix
  waydroid-idle-script = pkgs.writeShellScriptBin "waydroid-idle-manager" ''
    #!${pkgs.bash}/bin/bash

    # Конфигурация
    TIMEOUT_SECONDS=300 # 5 минут (300 секунд)

    # Переменные состояния
    last_seen_timestamp=0

    # Функция для проверки наличия окон WayDroid
    are_waydroid_windows_open() {
      # Получаем ID всех окон. Так как это пользовательский сервис,
      # ему доступны DISPLAY и права, не нужно sudo -u.
      local window_ids=$(${pkgs.xorg.xwininfo}/bin/xwininfo -root -children | grep "^\s\+0x" | awk '{print $1}')

      for id in $window_ids; do
        if ${pkgs.xorg.xprop}/bin/xprop -id "$id" WM_CLASS | grep -q "waydroid"; then
          return 0 # Окно найдено
        fi
      done

      return 1 # Окон не найдено
    }

    echo "WayDroid Idle Manager запущен для пользователя $USER."

    # Бесконечный цикл
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

      sleep 10 # Проверяем каждые 10 секунд
    done
  '';
in
{
  # Декларативно создаем и включаем наш пользовательский сервис-сторож
  systemd.user.services.waydroid-idle-manager = {
    # Секция [Unit]
    Unit = {
      Description = "WayDroid Idle Manager";
      After = [ "graphical-session.target" ];
    };

    # Секция [Service]
    Service = {
      ExecStart = "${waydroid-idle-script}/bin/waydroid-idle-manager";
      Restart = "always";
      RestartSec = 10;
    };

    # Секция [Install] - в Home Manager она ЕСТЬ и работает
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
