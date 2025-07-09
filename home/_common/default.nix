# home/_common/default.nix
# Финальная, исправленная версия
{ pkgs, inputs, ... }: # <-- Убедитесь, что здесь есть 'inputs'

{
  imports = [
    # --- ВОТ ОНО, ФИНАЛЬНОЕ РЕШЕНИЕ ---
    # Эта строка "учит" Home Manager понимать опции sops.*.
    # Она подключает модуль, который определяет 'sops.secrets'.
    inputs.sops-nix.homeManagerModules.sops,

    # Ваши существующие импорты остаются на месте
    ./options.nix,
    ./git.nix,
    ./waydroid-idle.nix
  ];

  # Базовые настройки Home Manager (без изменений)
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11";

  # Декларативно включаем наборы пакетов, общие для всех пользователей
  my.home.packages = {
    common = true;
  };
}
