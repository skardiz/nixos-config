# pkgs/default.nix
{ pkgs }:

{
  # Регистрируем наш новый пакет
  thorium-browser = pkgs.callPackage ./thorium-browser { };

  # Если в будущем появятся другие пакеты, добавляйте их сюда
  # another-package = pkgs.callPackage ./another-package { };
}
