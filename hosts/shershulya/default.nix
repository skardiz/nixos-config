# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # ... ваши существующие импорты ...
    ../_common/default.nix
    ../../modules/roles/desktop.nix
    ./hardware-configuration.nix
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  # --- НОВЫЙ БЛОК: НАСТРОЙКА СЕЙФА ---
  sops = {
    # Указываем, где лежит ПРИВАТНЫЙ ключ хоста, которым нужно
    # расшифровывать наши секреты.
    age.keyFile = "/etc/ssh/ssh_host_ed25519_key";

    # Определяем наш первый секрет. Мы даем ему имя "github_token".
    secrets.github_token = {
      # Указываем путь к зашифрованному файлу.
      # Путь считается от корня репозитория (где лежит flake.nix).
      sopsFile = ../../secrets.yaml;
    };
  };

  # --- ГЛАВНОЕ ИСПРАВЛЕНИЕ! ---
  # Мы настраиваем Nix декларативно, используя наш новый сейф.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Теперь мы берем токен не из текста, а из расшифрованного файла!
    # `config.sops.secrets.github_token` - это путь к временному файлу
    # с расшифрованным токеном, который sops-nix создаст при сборке.
    # Это БЕЗОПАСНО.
    access-tokens = "github.com=${config.sops.secrets.github_token}";
  };

  # --- Уникальные настройки для хоста 'shershulya' ---
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
