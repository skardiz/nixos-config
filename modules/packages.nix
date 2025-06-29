# modules/packages.nix
#
# Этот модуль отвечает за все кастомные пакеты и скрипты в системе.
{ lib, config, pkgs, ... }:

let
  # Создаем пакет из скрипта 'publish.sh'
  publish-script = pkgs.writeShellScriptBin "publish" (
    builtins.readFile ../scripts/publish.sh
  );

  # Создаем пакет из скрипта 'cleaner.sh'
  cleaner-script = pkgs.writeShellScriptBin "cleaner" (
    builtins.readFile ../scripts/cleaner.sh
  );
in
{
  # --- Объявляем опцию для включения наших скриптов ---
  options.my.packages.enableHelperScripts = lib.mkEnableOption "Включить вспомогательные скрипты (publish, cleaner)";

  # --- Связываем опцию с реальной установкой пакетов ---
  config = lib.mkIf config.my.packages.enableHelperScripts {
    environment.systemPackages = [
      publish-script
      cleaner-script
    ];
  };
}
