# modules/users.nix
#
# Наш собственный, высокоуровневый модуль для управления пользователями.
{ lib, config, self, inputs, mylib, ... }: # <-- Добавляем 'mylib' в аргументы

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
      (name: _:
        # Мы строим "чистый" путь от корня проекта, используя 'self'.
        import "${self}/home/${name}"
      )
      cfg.accounts;

    # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
    # 3. Передаем ВСЕ необходимые аргументы в модули Home Manager.
    # Раньше здесь не было 'mylib' и 'self'.
    home-manager.extraSpecialArgs = { inherit inputs self mylib; };

    # 4. Генерируем блок автологина для основного пользователя
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
