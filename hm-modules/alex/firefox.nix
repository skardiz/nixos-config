# /home/alex/nixos-config/hm-modules/alex/firefox.nix
{ ... }:
{
  programs.firefox = {
    enable = true;
    # Указываем русский языковой пакет напрямую
    languagePacks = [ "ru" ];

    profiles.alex = {
      isDefault = true;
      # Здесь можно будет добавлять *настоящие* расширения, если понадобится
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ... ];
    };
  };
}
