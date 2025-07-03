# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{ # <--- ОТКРЫВАЮЩАЯ СКОБКА, КОТОРОЙ НЕ БЫЛО

  imports = [
    ./hardware-configuration.nix
    ../_common/default.nix
    ../../modules/roles/desktop.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  sops = {
    # Указываем путь к приватному ключу age
    age.keyFile = "/etc/sops/keys/sops.key";

    # Указываем путь к зашифрованному файлу
    secrets.github_token = {
      sopsFile = ../../secrets.yaml;
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";
    extra-substituters = [ "https://nix-community.cachix.org" ];
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

} # <--- И ЗАКРЫВАЮЩАЯ СКОБКА

