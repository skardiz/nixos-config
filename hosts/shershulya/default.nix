# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, self, mylib, ... }: # Добавьте self и mylib

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    # ../../modules/hardware/intel-cpu.nix
    ../../modules/features/vpn.nix
  ];

  # Мы учреждаем группу 'sops' для управления доступом к ключу
  users.groups.sops = {};

  sops = {
    age.keyFile = "/etc/sops/keys/sops.key"; # Используем ключ, который мы разместили вручную
    defaultSopsFile = ../../secrets.yaml;
    secrets = {
      # Системный секрет для VPN
      vpn_private_key = {};

      # Системный секрет для Nix, который также нужен пользователю
      github_token = {
        neededForUsers = true;
      };

      # --- ВОТ ОНО ---
      # Мы объявляем личный секрет здесь, на уровне системы,
      # и помечаем, что он нужен пользователю.
      user_alex_ssh_private_key = {
        neededForUsers = true;
      };
    };
  };

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      # Даем Алексу доступ к группе 'sops', чтобы он мог читать секреты
      extraGroups = [ "adbusers" "sops" ];
      # Включаем опцию, которая будет использовать секрет
      home = {
        enableUserSshKey = true;
      };
    };
    mari = {
      description = "Mari";
      extraGroups = []; # Мари не имеет доступа к секретам
      home = {
        enableUserSshKey = false;
      };
    };
  };
}
