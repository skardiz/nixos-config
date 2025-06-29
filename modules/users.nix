# modules/users.nix
#
# Наш собственный, высокоуровневый модуль для управления пользователями.
{ lib, config, ... }:

let
  cfg = config.my.users;
in
{
  # --- Объявляем наш API для пользователей ---
  options.my.users.accounts = lib.mkOption {
    type = with lib.types; attrsOf (submodule {
      options = {
        isMainUser = mkEnableOption "Этот пользователь является основным (для автологина)";
        description = mkOption {
          type = str;
          default = "";
          description = "Полное имя пользователя.";
        };
        extraGroups = mkOption {
          type = listOf str;
          default = [];
          description = "Дополнительные группы для пользователя.";
        };
      };
    });
    default = {};
    description = "Декларативное описание всех пользователей в системе.";
  };

  # --- Генерируем конфигурацию на основе нашего API ---
  config = {
    # 1. Генерируем блок users.users
    users.users = lib.mapAttrs
      (name: userCfg: {
        isNormalUser = true;
        description = userCfg.description;
        extraGroups = [ "wheel" "networkmanager" "video" ] ++ userCfg.extraGroups;
      })
      cfg.accounts;

    # 2. Генерируем блок home-manager.users
    home-manager.users = lib.mapAttrs
      (name: _: import ../../home/${name})
      cfg.accounts;

    # 3. Генерируем блок автологина для основного пользователя
    services.displayManager.autoLogin =
      let
        # Находим всех пользователей, помеченных как isMainUser
        mainUsers = lib.filterAttrs (name: userCfg: userCfg.isMainUser) cfg.accounts;
        # Получаем имя первого (и единственного) такого пользователя
        mainUserName = lib.head (lib.attrNames mainUsers);
      in
      lib.mkIf (mainUsers != {}) {
        enable = true;
        user = mainUserName;
      };
  };
}
