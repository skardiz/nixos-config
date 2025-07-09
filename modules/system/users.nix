# modules/system/users.nix
{ lib, config, self, inputs, mylib, ... }:

let
  cfg = config.my.users;
in
{
  # --- Объявляем наш API для пользователей ---
  options.my.users.accounts = lib.mkOption {
    type = with lib.types; attrsOf (submodule {
      options = {
        isMainUser = lib.mkEnableOption "Этот пользователь является основным (для автологина)";
        description = lib.mkOption {
          type = str;
          default = "";
          description = "Полное имя пользователя.";
        };
        extraGroups = lib.mkOption {
          type = listOf str;
          default = [];
          description = "Дополнительные группы для пользователя.";
        };

        # --- ФИКС №1: Мы объявляем, что у каждого пользователя МОЖЕТ БЫТЬ блок 'home' ---
        # Теперь система не будет выдавать ошибку "option does not exist".
        home = lib.mkOption {
          type = lib.types.attrs;
          default = {};
          description = "Настройки Home Manager, специфичные для этого хоста.";
        };
      };
    });
    default = {};
    description = "Декларативное описание всех пользователей в системе.";
  };

  # --- Генерируем конфигурацию на основе нашего API ---
  config = {
    # 1. Генерируем блок users.users (без изменений)
    users.users = lib.mapAttrs
      (name: userCfg: {
        isNormalUser = true;
        description = userCfg.description;
        extraGroups = [ "wheel" "networkmanager" "video" ] ++ userCfg.extraGroups;
      })
      cfg.accounts;

    # 2. Генерируем блок home-manager.users
    home-manager.users = lib.mapAttrs
      (name: userCfg:
        # --- ФИКС №2: Мы объединяем общий файл пользователя (/home/alex/default.nix)
        # с настройками из блока 'home', который мы определили в хосте.
        # Это позволяет передавать 'enableUserSshKey = true;' из хоста в Home Manager.
        (import "${self}/home/${name}") // { my.home = userCfg.home; }
      )
      cfg.accounts;

    # 3. Передаем ВСЕ необходимые аргументы в модули Home Manager (без изменений)
    home-manager.extraSpecialArgs = { inherit inputs self mylib; };

    # 4. Генерируем блок автологина (без изменений)
    services.displayManager.autoLogin =
      let
        mainUsers = lib.filterAttrs (name: userCfg: userCfg.isMainUser) cfg.accounts;
        mainUserName = lib.head (lib.attrNames mainUsers);
      in
      lib.mkIf (mainUsers != {}) {
        enable = true;
        user = mainUserName;
      };
  };
}
