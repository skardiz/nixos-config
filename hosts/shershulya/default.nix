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

  # 2. Сообщаем системному sops-nix, где будет лежать ключ
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  sops.defaultSopsFile = ../../secrets.yaml;
  # 3. Объявляем ВСЕ секреты здесь, на уровне системы
  sops.secrets = {
    vpn_private_key = {};
    github_token = {}; # neededForUsers = true здесь больше не нужно, гонка решена иначе
    user_alex_ssh_private_key = {};
  };

  # 4. "Разрешение на существование": Декларативно управляем файлом ключа,
  # чтобы NixOS его не удаляла. Источник - абсолютный путь к вашему найденному ключу.
  environment.etc."sops/keys/sops.key" = {
    source = "/home/alex/.config/sops/age/keys.txt";
    group = "sops";
    mode = "0440"; # Чтение для root и группы 'sops'
  };

  # 5. "Порядок действий": Решаем "гонку состояний" для скрипта, который
  # использует sops для системных нужд.
  system.activationScripts.setupSecrets.deps = [ "etc" ];

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      # Даем Алексу доступ к группе 'sops', чтобы его Home Manager мог прочитать ключ
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
