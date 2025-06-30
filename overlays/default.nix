# overlays/default.nix
#
# Наш единый и единственный центр управления всеми кастомными пакетами.
final: prev: {
  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
  # Мы убираем пустые скобки `{}`. Теперь `prev.callPackage`
  # будет автоматически искать ВСЕ недостающие зависимости
  # (вроде `cpp-httplib` и `openssl`) в основном наборе пакетов `prev`.
  dpitunnel = prev.callPackage ../pkgs/dpitunnel;

  # Для второго пакета делаем то же самое.
  #thorium-browser = prev.callPackage ../pkgs/thorium-browser;
}
