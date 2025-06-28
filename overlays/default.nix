# overlays/default.nix
self: super:

let
  # Импортируем все наши кастомные пакеты из папки `pkgs`
  # Мы передаем `super` в качестве `pkgs`, чтобы наши пакеты
  # могли использовать зависимости из стандартного nixpkgs.
  customPkgs = import ../pkgs { pkgs = super; };
in
# Добавляем наши кастомные пакеты в финальный набор пакетов.
# Например, если в customPkgs есть `thorium-browser`, он станет
# доступен как `pkgs.thorium-browser`.
customPkgs
