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

  # --- ПРОСТАЯ И НАДЕЖНАЯ КОНФИГУРАЦИЯ SOPS ---
  sops = {
    # Мы просто указываем путь к файлу с секретами.
    defaultSopsFile = ../../secrets.yaml;

    # И мы включаем поддержку расшифровки через SSH ключи хоста.
    # sops-nix сам найдет нужный ключ в /etc/ssh.
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Определяем наш секрет. Пустые скобки означают "использовать
    # настройки по умолчанию", которые нам подходят (владелец - root).
    secrets.github_token = {};
  };

  # Настройки Nix.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";
    extra-substituters = [ "https://nix-community.cachix.org" ];
    # Используем правильный ключ с МИНУСОМ, а не подчеркиванием.
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2-jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
  };

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
