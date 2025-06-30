# overlays/default.nix
#
# Наш единый и единственный центр управления всеми кастомными пакетами.
final: prev: {
  # Инструкция по сборке "лазерного резака" DPITunnel.
  # Мы используем `prev.callPackage`, чтобы он сам нашел все зависимости.
  dpitunnel = prev.callPackage ../pkgs/dpitunnel { };

  # Инструкция по сборке браузера Thorium.
  thorium-browser = prev.callPackage ../pkgs/thorium-browser { };
}
