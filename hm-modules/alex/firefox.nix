# /home/alex/nixos-config/hm-modules/alex/firefox.nix
{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.alex = {
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        { package = pkgs.firefox-i18n-ru; }
      ];
    };
  };
}
