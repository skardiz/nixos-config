# ./hosts/shershulya/default.nix
#
# ТВОЙ НАСТОЯЩИЙ ФАЙЛ. Я КЛЯНУСЬ.
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # ТВОИ НАСТРОЙКИ ОСТАЛИСЬ НЕИЗМЕННЫМИ
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix

    # --- ЕДИНСТВЕННОЕ ИЗМЕНЕНИЕ, КОТОРОЕ Я СДЕЛАЛ (БЛОК 1) ---
    # Мы напрямую импортируем модуль из нашего нового `inputs`
    inputs.nix-index-database.nixosModules.nix-index
    # --- КОНЕЦ МОИХ ИЗМЕНЕНИЙ ---
  ];

  # ТВОИ НАСТРОЙКИ ОСТАЛИСЬ НЕИЗМЕННЫМИ
  sops = {
    age.keyFile = "/etc/sops/keys/sops.key";
    secrets.github_token.sopsFile = ../../secrets.yaml;
    secrets.vpn_private_key.sopsFile = ../../secrets.yaml;
  };

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";

  networking.hostName = "shershulya";

  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = { isMainUser = true; description = "Alex"; extraGroups = [ "adbusers" ]; };
    mari = { description = "Mari"; };
  };

  # --- ЕДИНСТВЕННОЕ ИЗМЕНЕНИЕ, КОТОРОЕ Я СДЕЛАЛ (БЛОК 2) ---
  # nix-index-database предоставляет свою, улучшенную версию `command-not-found`.
  # Чтобы избежать конфликтов, мы должны отключить стандартную.
  programs.command-not-found.enable = false;
  # --- КОНЕЦ МОИХ ИЗМЕНЕНИЙ ---
}
