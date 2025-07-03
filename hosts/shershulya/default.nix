# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../_common/default.nix
    ../../modules/roles/desktop.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  # --- ФИНАЛЬНОЕ, КЛАССИЧЕСКОЕ РЕШЕНИЕ ---
  # Мы создаем один, правильный блок для sops.
  sops = {
    # 1. Мы явно указываем путь к файлу с секретами по умолчанию.
    #    Это исправляет ошибку 'sops.defaultSopsFile was accessed but has no value defined'.
    defaultSopsFile = ../../secrets.yaml;

    # 2. Мы явно указываем путь к нашему ПРИВАТНОМУ ключу.
    age.keyFile = "/etc/ssh/ssh_host_ed25519_key";

    # 3. Мы определяем наш секрет.
    secrets.github_token = {
      # 4. Мы указываем, что владелец расшифрованного файла - root,
      #    так как системные службы (вроде nix-daemon) работают от его имени.
      owner = config.users.users.root.name;
    };
  };

  # Настройки Nix остаются без изменений.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2_jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
  };

  # ... остальная часть вашей конфигурации ...
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";
  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      extraGroups = [ "adbusers" ];
    };
    mari = {
      description = "Mari";
    };
  };
}
