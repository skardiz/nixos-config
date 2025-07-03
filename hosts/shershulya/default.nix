# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
  ];

  # --- НАСТРОЙКИ, УНИКАЛЬНЫЕ ДЛЯ ЭТОГО ХОСТА ---

  # SOPS: Настраиваем Sops. Он уже импортирован из modules/system.
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
