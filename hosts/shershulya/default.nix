# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # ... ваши существующие импорты ...
  ];

  # Настройка сейфа остается без изменений.
  sops = {
    age.keyFile = "/etc/ssh/ssh_host_ed25519_key";
    secrets.github_token = {
      sopsFile = ../../secrets.yaml;
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # --- ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЗДЕСЬ! ---
    # Мы явно указываем, что нам нужен именно `.path` из всего набора.
    # Это путь к временному файлу, который sops-nix создаст при сборке.
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";

    # Эти строки можно оставить, они полезны
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2_jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
  };

  # ... остальная часть вашей конфигурации ...
}
