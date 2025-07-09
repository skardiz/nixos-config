# hosts/shershulya/default.nix
{ inputs, self, mylib, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/features/vpn.nix
  ];

  # Учреждаем группу, которой будет дозволено читать ключ
  users.groups.sops = {};

  # Мы просто говорим системному sops-nix, где лежит ЕГО ключ.
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  sops.defaultSopsFile = ../../secrets.yaml;
  sops.secrets = {
    vpn_private_key = {};
    github_token = { neededForUsers = true; };
    # Секрет для SSH-ключа Алекса здесь больше не нужен,
    # так как он будет управляться на уровне Home Manager
  };

  # Мы берем на себя ответственность за создание файла ключа
  environment.etc."sops/keys/sops.key" = {
    source = "${self}/sops.key"; # Предполагается, что sops.key лежит в корне проекта
    group = "sops";
    mode = "0440"; # Чтение для владельца (root) и группы (sops)
  };

  # --- ФИНАЛЬНОЕ РЕШЕНИЕ ГОНКИ СОСТОЯНИЙ ---
  system.activationScripts.sops-secrets.deps = [ "etc" ];

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  # Принимаем пользователей в группу 'sops', даруя им право читать ключ
  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      # Только Алекс состоит в группе sops
      extraGroups = [ "adbusers" "sops" ];
      home.enableUserSshKey = true; # Ваша опция для активации sops в home-manager
    };
    mari = {
      description = "Mari";
      # Мари НЕ состоит в группе sops
      extraGroups = [];
      home.enableUserSshKey = false; # У Мари эта опция выключена
    };
  };
}
