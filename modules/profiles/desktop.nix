# modules/profiles/desktop.nix
#
# Это универсальный профиль ("набор LEGO") для любого вашего "основного десктопа".
# Он включает в себя все необходимые фичи и настройки по умолчанию.
{
  imports = [
    # Подключаем "кирпичики"-фичи
    ../features/desktop.nix
    ../features/gaming.nix
    ../features/android.nix
    # ../features/vpn.nix
  ];

 # --- НОВЫЙ РАЗДЕЛ ЗДЕСЬ! ---
  # Определяем стандарт загрузки для всех наших десктопов
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # Устанавливаем таймаут выбора системы в 0 секунд для мгновенной загрузки
    loader.timeout = 0;

    # Все наши десктопы по умолчанию используют ядро Zen
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
