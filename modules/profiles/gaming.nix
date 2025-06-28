# modules/gaming.nix
{ pkgs, config, ... }: # Добавим 'config' и '...' на всякий случай, если будут другие опции

{
  environment.sessionVariables = { MANGOHUD = "1"; };

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamemode.enable = true;

  # Добавляем gamescope в системные пакеты
  environment.systemPackages = with pkgs; [
    gamescope
  ];

  # Опционально: если вы хотите использовать Gamescope как сессию в GDM/SDDM
  # services.displayManager.sessionPackages = [ pkgs.gamescope ];

  # Опционально: если вы хотите установить Gamescope как композитор по умолчанию для Steam (Steam Big Picture Mode)
  # programs.steam.gamescopeSession.enable = true; # Это для специфических интеграций Steam
}
