# home/_common/waydroid-idle.nix
# Этот модуль использует хелпер для генерации сложного скрипта.
{ pkgs, mylib, ... }: # <-- Добавляем 'mylib' в аргументы

let
  # Генерируем скрипт-сторож, вызывая наш новый хелпер.
  # Передаем ему 'pkgs', так как они нужны для создания скрипта.
  waydroid-idle-script = mylib.myHelpers.makeWaydroidIdleScript { inherit pkgs; };
in
{
  # Декларативно создаем и включаем наш пользовательский сервис-сторож.
  # Этот блок остается без изменений, но теперь он использует
  # результат работы нашего чистого хелпера.
  systemd.user.services.waydroid-idle-manager = {
    Unit = {
      Description = "WayDroid Idle Manager";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${waydroid-idle-script}/bin/waydroid-idle-manager";
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
