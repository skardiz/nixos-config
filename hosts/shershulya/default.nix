# hosts/shershulya/default.nix
{ inputs, self, mylib, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    # ../../modules/features/vpn.nix
  ];

  # Мы больше НЕ создаем группу sops.

  # Системный sops-nix теперь САМ управляет своим ключом.
  # Он создаст /etc/sops/keys/sops.key из этого источника
  # и установит на него права "только для root".
  sops.age.keyFile = "${self}/sops.key";

  sops.defaultSopsFile = ../../secrets.yaml;
  # Система отвечает ТОЛЬКО за системные секреты.
  sops.secrets = {
    # vpn_private_key = {};
    github_token = { neededForUsers = true; };
  };

  # Мы больше НЕ используем environment.etc или activationScripts для ключа.
  # sops-nix теперь делает все сам, атомарно и без конфликтов.

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      # Группа sops больше не нужна
      extraGroups = [ "adbusers" ];
      home = {
        enableUserSshKey = true;
      };
    };
    mari = {
      description = "Mari";
      extraGroups = [];
      home = {
        enableUserSshKey = false;
      };
    };
  };
}
