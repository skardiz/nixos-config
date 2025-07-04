# ./hosts/shershulya/default.nix (РАБОЧАЯ ВЕРСИЯ БЕЗ NIX-INDEX)
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  sops = {
    age.keyFile = "/etc/sops/keys/sops.key";
    secrets.github_token.sopsFile = ../../secrets.yaml;
    secrets.vpn_private_key.sopsFile = ../../secrets.yaml;
  };

  # Мы оставляем эту строку. Она не виновата. Виновата попытка
  # использовать ее для публичных репозиториев.
  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";

  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = { isMainUser = true; description = "Alex"; extraGroups = [ "adbusers" ]; };
    mari = { description = "Mari"; };
  };
}
