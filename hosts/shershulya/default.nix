# ./hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  # Мы больше НЕ импортируем modules/system здесь,
  # так как это делается на уровне flake.nix
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
  ];

  # --- НАСТРОЙКИ, УНИКАЛЬНЫЕ ДЛЯ ЭТОГО ХОСТА ---

  # SOPS: Активируем и настраиваем Sops для этого хоста
  sops = {
    age.keyFile = "/etc/sops/keys/sops.key";
    secrets.github_token.sopsFile = ../../secrets.yaml;
    secrets.vpn_private_key.sopsFile = ../../secrets.yaml;
  };

  # NIX: Добавляем только ту настройку, которая зависит от sops этого хоста.
  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";

  # Уникальное имя хоста и версия системы.
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  # Уникальные пользователи для этого хоста.
  my.users.accounts = {
    alex = { isMainUser = true; description = "Alex"; extraGroups = [ "adbusers" ]; };
    mari = { description = "Mari"; };
  };
}
