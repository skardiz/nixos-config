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
    #../features/android.nix
    ../features/dpi-tunnel.nix
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
    locale.enableRussian = true;
    optimizations = {
      enableSsdTweaks = true;
      enableZlibNg = true;
      enableDesktopResponsiveness = true;
    };
  };
}
