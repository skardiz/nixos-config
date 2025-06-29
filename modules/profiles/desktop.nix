# modules/profiles/desktop.nix
#
# Это универсальный профиль ("набор LEGO") для любого вашего "основного десктопа".
# --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
# Мы превращаем этот файл в функцию, которая принимает 'pkgs' в качестве аргумента.
{ pkgs, ... }:

{
  imports = [
    # Подключаем "кирпичики"-фичи
    ../features/desktop.nix
    ../features/gaming.nix
    ../features/android.nix
    # ../features/vpn.nix
  ];

  # Определяем стандарт загрузки для всех наших десктопов
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;

    # Теперь 'pkgs' здесь известен, и эта строка будет работать
    kernelPackages = pkgs.linuxPackages_zen;
  };

  # Настройки по умолчанию для этого профиля
  my = {
    packages.enableHelperScripts = true;
    locale.enableRussian = true;
    optimizations = {
      enableSsdTweaks = true;
      enableZlibNg = true;
      enableDesktopResponsiveness = true;
    };
  };
}
