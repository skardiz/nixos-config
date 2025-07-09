# modules/system/users.nix
{ lib, config, self, inputs, mylib, ... }:

let
  cfg = config.my.users;
in
{
  # --- Объявляем наш API для пользователей (включая опцию 'home') ---
  options.my.users.accounts = lib.mkOption {
    type = with lib.types; attrsOf (submodule {
      options = {
        isMainUser = lib.mkEnableOption "Этот пользователь является основным (для автологина)";
        description = lib.mkOption { type = str; default = ""; };
        extraGroups = lib.mkOption { type = listOf str; default = []; };
        home = lib.mkOption {
          type = lib.types.attrs;
          default = {};
          description = "Настройки Home Manager, специфичные для этого хоста.";
        };
      };
    });
    default = {};
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

    # --- ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЗДЕСЬ ---
    # 2. Генерируем блок home-manager.users ПРАВИЛЬНО
    home-manager.users = lib.mapAttrs
      (name: userCfg: {
        # Мы НЕ импортируем файл здесь. Мы говорим home-manager, ЧТО ему нужно импортировать.
        # Это ключ к решению.
        imports = [ "${self}/home/${name}" ];

        # Теперь мы можем безопасно добавить host-specific настройки из 'home'.
        my.home = userCfg.home;
      })
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
