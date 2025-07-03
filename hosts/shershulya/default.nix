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

  sops = {
    age.keyFile = "/etc/ssh/ssh_host_ed25519_key";

    # Мы отключаем автоматическое сканирование ключей, чтобы
    # избежать любых двусмысленностей.
    age.sshKeyPaths = [];

    secrets.github_token = {
      sopsFile = ../../secrets.yaml;
      owner = config.users.users.root.name;

      # --- ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
      # Это — встроенная в sops-nix опция, которая правильно решает
      # проблему гонки состояний. Она гарантирует, что секрет будет
      # расшифрован до того, как он понадобится системным службам.
      neededForBoot = true;
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2_jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
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
