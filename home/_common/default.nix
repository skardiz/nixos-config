# home/_common/default.nix
# Этот файл собирает все общие модули для пользователей.
{ ... }:
{
  imports = [
    ./bash.nix
    ./git.nix
    ./waydroid-idle.nix
  ];
}
