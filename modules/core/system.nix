# modules/system.nix
{ pkgs, lib, config, self, ... }:

let
  # --- Блок для создания простой и чистой метки ---
  dateString = self.lastModifiedDate or "19700101000000";
  dateParts = builtins.match "(.{4})(.{2})(.{2})(.{2})(.{2}).*" dateString;

  nixosLabel =
    if dateParts != null
    then
      let
        day = builtins.elemAt dateParts 2;
        month = builtins.elemAt dateParts 1;
        hour = builtins.elemAt dateParts 3;
        minute = builtins.elemAt dateParts 4;
      in "${hour}:${minute}-${day}.${month}"
    else "unknown-datetime"; # Запасной вариант

in

{
  # -------------------------------------------------------------------
  # Настройки Nix
  # -------------------------------------------------------------------
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  # -------------------------------------------------------------------
  # Настройки загрузчика
  # -------------------------------------------------------------------
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  # -------------------------------------------------------------------
  # Основные системные настройки
  # -------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  system.nixos.label = nixosLabel; # Устанавливаем нашу простую и чистую метку.
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console.keyMap = "ru";

  # -------------------------------------------------------------------
  # Сеть и общие системные пакеты
  # -------------------------------------------------------------------
  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  networking.useNetworkd = true;
  systemd.network.enable = true;

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "rebuild" (builtins.readFile ../scripts/rebuild.sh))
    (writeShellScriptBin "cleaner" (builtins.readFile ../scripts/cleaner.sh))
  ];
}
