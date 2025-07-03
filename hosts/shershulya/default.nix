# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # --- ВОТ ОНА, НАША ОШИБКА! ---
    # Мы должны импортировать файл, который описывает наше железо,
    # файловые системы и загрузчик.
    ./hardware-configuration.nix

    # Все остальные импорты остаются на месте.
    ../_common/default.nix
    ../../modules/roles/desktop.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  # Настройки sops остаются без изменений.
  sops = {
    age.keyFile = "/etc/ssh/ssh_host_ed25519_key";
    secrets.github_token = {
      sopsFile = ../../secrets.yaml;
    };
  };

  # Настройки Nix остаются без изменений.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2_jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
  };

  # Уникальные настройки хоста остаются без изменений.
  networking.hostName = "shershulya";
  # system.stateVersion = "25.11"; # <-- Вы можете раскомментировать это, чтобы убрать предупреждение.

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
