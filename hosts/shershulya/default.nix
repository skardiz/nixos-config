# hosts/shershulya/default.nix
{ inputs, self, mylib, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    # Если у вас есть другие импорты, например, vpn.nix, оставьте их
    # ../../modules/features/vpn.nix
  ];

  # Учреждаем группу, которой будет дозволено читать ключ
  users.groups.sops = {};

  # Мы просто говорим системному sops-nix, где лежит ЕГО ключ.
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  sops.defaultSopsFile = ../../secrets.yaml;
  sops.secrets = {
    # vpn_private_key = {};
    github_token = { neededForUsers = true; };
  };

  # Мы берем на себя ответственность за создание файла ключа
  environment.etc."sops/keys/sops.key" = {
    source = "${self}/sops.key"; # Предполагается, что sops.key лежит в корне проекта
    group = "sops";
    mode = "0440"; # Чтение для владельца (root) и группы (sops)
  };

  # --- ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЗДЕСЬ ---
  # Мы устанавливаем зависимость для ПРАВИЛЬНОГО имени скрипта,
  # который используется для секретов с 'neededForUsers = true'.
  # Имя скрипта по умолчанию - "setupSecrets".
  system.activationScripts.setupSecrets.deps = [ "etc" ];

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  # Принимаем пользователей в группу 'sops', даруя им право читать ключ
  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      extraGroups = [ "adbusers" "sops" ];
      home = {
        enableUserSshKey = true;
        # Если у вас были другие опции, например packages.dev, они тоже должны быть здесь
        # packages.dev = true;
      };
    };
    mari = {
      description = "Mari";
      extraGroups = []; # Мари НЕ состоит в группе sops
      home = {
        enableUserSshKey = false; # Явно выключаем для Мари
        # packages.dev = false;
      };
    };
  };
}
