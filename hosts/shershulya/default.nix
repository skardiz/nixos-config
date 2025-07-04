# ./hosts/shershulya/default.nix
#
# Финальная, единственно правильная версия от Дедушки-Кузнеца
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
    ../../modules/features/filebrowser.nix
  ];

  sops = {
    age.keyFile = "/etc/sops/keys/sops.key";
    defaultSopsFile = ../../secrets.yaml; # Для удобства можно указать файл по умолчанию
    secrets = {
      vpn_private_key = {}; # sops сам найдет его в defaultSopsFile
      github_token = {
        # --- ВОТ ОНО, ИСТИННОЕ ЛЕКАРСТВО ---
        # Эта строка говорит: "Этот секрет нужен пользователям.
        # Подготовь его ДО активации Home Manager".
        # Это разрывает цикл зависимости.
        neededForUsers = true;
      };
    };
  };

  # Эта настройка остается. Она правильная.
  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";

  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = { isMainUser = true; description = "Alex"; extraGroups = [ "adbusers" ]; };
    mari = { description = "Mari"; };
  };
}
