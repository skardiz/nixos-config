# ./hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  # Мы больше НЕ импортируем modules/system здесь,
  # так как это делается на уровне flake.nix
  imports = [
    ./hardware-configuration.nix
    ../../modules/roles/desktop.nix
    ../../modules/roles/developer.nix
    # --- ВОЗВРАЩАЕМ УКРАДЕННОЕ ---
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  # --- НАСТРОЙКИ, УНИКАЛЬНЫЕ ДЛЯ ЭТОГО ХОСТА ---
  sops = {
    age.keyFile = "/etc/sops/keys/sops.key";
    secrets.github_token.sopsFile = ../../secrets.yaml;
    secrets.vpn_private_key.sopsFile = ../../secrets.yaml;
  };

  nix.settings.access-tokens = "github.com=${config.sops.secrets.github_token.path}";

  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  my.users.accounts = {
    alex = { isMainUser = true; description = "Alex"; extraGroups = [ "adbusers" ]; };
    mari = { description = "Mari"; };
  };
}
