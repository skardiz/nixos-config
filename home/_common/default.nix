# home/_common/default.nix
# Финальная, исправленная версия
{ pkgs, inputs, ... }: # <-- Убедитесь, что здесь есть 'inputs'

{
  imports = [
    # Эта строка "учит" Home Manager понимать опции sops.*
    inputs.sops-nix.homeManagerModules.sops

    # Ваши существующие импорты
    ./options.nix
    ./git.nix
    ./waydroid-idle.nix
  ];

 # --- ВОТ ОНО, ИСПРАВЛЕНИЕ ---
  # Мы сообщаем личному sops-nix, где находится ключ, который
  # ему разрешено читать благодаря членству в группе 'sops'.
  # Это устраняет ошибку "No key source configured".
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  # Базовые настройки Home Manager (без изменений)
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";

  # Декларативно включаем наборы пакетов, общие для всех пользователей
  my.home.packages = {
    common = true;
  };
}
