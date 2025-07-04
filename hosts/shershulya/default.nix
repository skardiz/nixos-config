# ./hosts/shershulya/default.nix
#
# Финальная, единственно правильная версия от Дедушки-с-рыжей-бородой
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
    # Эта строка остается, она подключает модуль, который скачает базу
    inputs.nix-index-database.nixosModules.nix-index
  ];

  sops = {
    age.keyFile = "/etc/sops/keys/sops.key";
    secrets.github_token.sopsFile = ../../secrets.yaml;
    secrets.vpn_private_key.sopsFile = ../../secrets.yaml;
  };

  # --- ВОТ ОНА, НАСТОЯЩАЯ МАГИЯ ---
  # Мы меняем глобальный "github.com" на точный путь к ТВОЕМУ репозиторию.
  # Теперь токен будет использоваться ТОЛЬКО для него, а все остальные
  # репозитории на GitHub будут доступны анонимно.
  nix.settings.access-tokens = "github.com/skardiz/nixos-config=${config.sops.secrets.github_token.path}";

  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = { isMainUser = true; description = "Alex"; extraGroups = [ "adbusers" ]; };
    mari = { description = "Mari"; };
  };

  # Эта строка остается, она нужна для правильной работы nix-index
  programs.command-not-found.enable = false;
}
