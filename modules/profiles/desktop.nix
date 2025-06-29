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

  # Включаем переключатели по умолчанию для этого профиля
  my = {
    locale.enableRussian = true;
    optimizations = {
      enableSsdTweaks = true;
      enableZlibNg = true;
      enableDesktopResponsiveness = true;
    };
    # Политики и другие глобальные вещи мы определяем в "Конституции"
  };
}
