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

  # 1. Учреждаем группу 'sops' для управления доступом к ключу
  users.groups.sops = {};

  # 2. Сообщаем sops-nix, где будет лежать ключ
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  sops.defaultSopsFile = ../../secrets.yaml;
  # 3. Объявляем ВСЕ секреты здесь, на уровне системы
  sops.secrets = {
    vpn_private_key = {};
    github_token = { neededForUsers = true; };
    user_alex_ssh_private_key = { neededForUsers = true; };
  };

  # --- ФИНАЛЬНОЕ РЕШЕНИЕ (ЧАСТЬ 1): "РАЗРЕШЕНИЕ НА СУЩЕСТВОВАНИЕ" ---
  # Мы декларативно управляем файлом ключа, чтобы NixOS его не удаляла.
  # Источник - НЕ в /nix/store, а по абсолютному пути, что решает проблему безопасности.
  environment.etc."sops/keys/sops.key" = {
    source = "/home/alex/.config/sops/age/keys.txt"; # Путь к вашему найденному ключу
    group = "sops";
    mode = "0440"; # Чтение для root и группы 'sops'
  };

  # --- ФИНАЛЬНОЕ РЕШЕНИЕ (ЧАСТЬ 2): "ПОРЯДОК ДЕЙСТВИЙ" ---
  # Мы решаем "гонку состояний" для ОБОИХ скриптов, которые использует sops-nix.
  system.activationScripts.setupSecrets.deps = [ "etc" ];
  system.activationScripts.setupSecretsForUsers.deps = [ "etc" ];

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      # Даем Алексу доступ к группе 'sops', чтобы его Home Manager мог читать ключ
      extraGroups = [ "adbusers" "sops" ];
      home = { enableUserSshKey = true; };
    };
    mari = {
      description = "Mari";
      extraGroups = []; # Мари НЕ состоит в группе sops
      home = { enableUserSshKey = false; };
    };
  };
}
