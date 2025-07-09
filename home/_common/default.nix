# home/_common/default.nix
{ pkgs, inputs, ... }: # <-- Добавьте 'inputs' в аргументы

{
  imports = [
    # --- ВОТ ОНО, ФИНАЛЬНОЕ РЕШЕНИЕ ---
    # Мы подключаем модуль sops-nix для Home Manager.
    # Теперь система будет знать, что такое "sops.secrets".
    inputs.sops-nix.homeManagerModules.sops,

    # Все остальные ваши импорты остаются на месте
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
