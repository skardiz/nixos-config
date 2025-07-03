# modules/system/nix.nix
{ pkgs, ... }:

{
  # Эта опция — НАСТОЯЩАЯ. Она говорит NixOS: "Возьми все настройки из
  # блока nix.settings и сделай их глобальными, записав в /etc/nix/nix.conf".
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Здесь мы определяем сами настройки.
  nix.settings = {
    # Эта настройка будет добавлена в nix.conf через extraOptions,
    # но мы оставляем ее здесь для консистентности.
    experimental-features = [ "nix-command" "flakes" ];

    # Эти настройки общие для всех хостов.
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9UfP3dPH2-jeLqIphSkeUV3ZTLb61E4gD4sIC=" ];
  };
}
