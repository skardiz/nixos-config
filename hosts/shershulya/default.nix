# hosts/shershulya/default.nix
{ config, pkgs, inputs, lib, ... }:

{ # <--- Главная открывающая скобка

  imports = [
    # Подключаем описание нашего железа (диски, загрузчик).
    ./hardware-configuration.nix

    # Подключаем общие для всех хостов правила.
    ../_common/default.nix

    # Подключаем "роль" рабочего стола, которая собирает все нужные фичи.
    ../../modules/roles/desktop.nix

    # Подключаем модули для нашего конкретного оборудования.
    ../../modules/hardware/nvidia-pascal.nix
    ../../modules/hardware/intel-cpu.nix
  ];

  # --- ГЛАВНОЕ ИСПРАВЛЕНИЕ ДЛЯ NIX-SHELL ---
  # Эта опция говорит NixOS: "Возьми все настройки из блока nix.settings
  # и сделай их глобальными, записав в /etc/nix/nix.conf".
  # Это сделает твой flake.nix единственным источником правды.
  nix.generateNixPath = true;

  # --- НАДЕЖНАЯ КОНФИГУРАЦИЯ SOPS ---
  sops = {
    # Указываем прямой, недвусмысленный путь к нашему НОВОМУ,
    # НАСТОЯЩЕМУ приватному ключу.
    age.keyFile = "/etc/sops/keys/sops.key";

    # Определяем наш секрет.
    secrets.github_token = {
      sopsFile = ../../secrets.yaml;
    };
  };

  # --- ЕДИНЫЙ ИСТОЧНИК НАСТРОЕК NIX ---
  nix.settings = {
    # Эти настройки теперь будут применяться ко всей системе.
    experimental-features = [ "nix-command" "flakes" ];
    access-tokens = "github.com=${config.sops.secrets.github_token.path}";
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2-jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
  };

  # --- УНИКАЛЬНЫЕ НАСТРОЙКИ ХОСТА ---
  networking.hostName = "shershulya";
  system.stateVersion = "25.11";

  # --- ПОЛЬЗОВАТЕЛИ ---
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

} # <--- Главная закрывающая скобка
