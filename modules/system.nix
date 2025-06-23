# modules/system.nix
{ pkgs, lib, config, self, ... }:

let
  # --- Блок для создания метки поколения (ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ) ---

  # 1. Получаем короткий хэш коммита.
  commitHash = self.shortRev or "dirty";

  # 2. Получаем дату последнего коммита в виде строки "YYYYMMDDHHMMSS".
  dateString = self.lastModifiedDate or "19700101000000";
  dateParts = builtins.match "(.{4})(.{2})(.{2}).*" dateString;
  formattedDate =
    if dateParts != null
    then "${builtins.elemAt dateParts 2}.${builtins.elemAt dateParts 1}.${builtins.elemAt dateParts 0}"
    else "unknown-date";

  # --- ИСПРАВЛЕНИЕ ЗДЕСЬ ---
  # 3. Собираем финальную строку, используя ТОЛЬКО разрешенные символы.
  #    Заменяем пробелы и скобки на дефисы.
  nixosLabel = "${config.system.stateVersion}-${formattedDate}-${commitHash}";

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
  # Настройки оборудования и загрузки
  # -------------------------------------------------------------------
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  # -------------------------------------------------------------------
  # Основные системные настройки
  # -------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  # Устанавливаем нашу кастомную, валидную метку.
  system.nixos.label = nixosLabel;

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console.keyMap = "ru";

  # -------------------------------------------------------------------
  # Сеть и системные пакеты
  # -------------------------------------------------------------------
  networking.hostName = "shershulya";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "rebuild" (builtins.readFile ../scripts/rebuild.sh))
  ];
}
