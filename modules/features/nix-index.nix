# modules/features/nix-index.nix
# Включает nix-index и использует готовую базу данных от сообщества
# для экономии времени и ресурсов.
{ pkgs, ... }:

{
  programs.nix-index = {
    enable = true;
    # Используем готовую базу данных
    enableZshIntegration = true; # Если используешь Zsh
    package = pkgs.nix-index;
  };

  # Добавляем сервис, который будет автоматически скачивать базу
  systemd.services.nix-index = {
    serviceConfig.ExecStart = ''
      ${pkgs.nix-index}/bin/nix-index --build-database-from-url https://github.com/Mic92/nix-index-database/releases/download/master/files
    '';
  };
}
