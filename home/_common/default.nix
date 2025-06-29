# home/_common/default.nix
# Этот файл собирает все общие модули для пользователей.
{ ... }:
{
  imports = [
    ./git.nix
    ./waydroid-idle.nix
  ];
}
