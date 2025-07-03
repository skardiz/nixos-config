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
    secrets.github_token = {
      sopsFile = ../../secrets.yaml;
      owner = config.users.users.root.name;
    };
  }; # <--- ИСПРАВЛЕНИЕ №1: Здесь, скорее всего, отсутствовала ;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2_jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
  }; # <--- ИСПРАВЛЕНИЕ №2: И здесь тоже.

  networking.hostName = "shershulya"; # <--- ИСПРАВЛЕНИЕ №3: И здесь.

  system.stateVersion = "25.11"; # <--- ИСПРАВЛЕНИЕ №4: И здесь.

  my.users.accounts = {
    alex = {
      isMainUser = true;
      description = "Alex";
      extraGroups = [ "adbusers" ];
    };
    mari = {
      description = "Mari";
    };
  }; # <--- В конце последнего атрибута точка с запятой не нужна.
}

