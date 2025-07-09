# hosts/shershulya/default.nix
{ inputs, self, mylib, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    # ../../modules/features/vpn.nix # Если нужно
  ];

  # Мы учреждаем группу 'sops' для управления доступом к ключу
  users.groups.sops = {};

  # Мы больше НЕ управляем файлом ключа через environment.etc или activationScripts.

  # Мы просто сообщаем sops-nix, где найти ключ, который мы разместили вручную.
  sops.age.keyFile = "/etc/sops/keys/sops.key";

  sops.defaultSopsFile = ../../secrets.yaml;
  sops.secrets = {
    # vpn_private_key = {};
    github_token = {}; # neededForUsers здесь больше не нужно, так как нет гонки состояний
  };

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      # Даем Алексу доступ к группе 'sops', чтобы его Home Manager мог прочитать ключ
      extraGroups = [ "adbusers" "sops" ];
      home = {
        enableUserSshKey = true;
      };
    };
    mari = {
      description = "Mari";
      extraGroups = []; # Мари НЕ состоит в группе sops
      home = {
        enableUserSshKey = false;
      };
    };
  };
}
