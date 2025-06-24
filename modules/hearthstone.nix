# /home/alex/nixos-config/modules/hearthstone.nix
{ pkgs, ... }:

{
  # Включаем nix-ld, чтобы запускать бинарные файлы,
  # скомпилированные не под NixOS.
  programs.nix-ld.enable = true;

  # Указываем, какие библиотеки должны быть доступны через nix-ld.
  programs.nix-ld.libraries = with pkgs; [
    # Графика и OpenGL/Vulkan
    libglvnd
    libGL # <--- ИСПРАВЛЕНИЕ: Правильное имя пакета
    vulkan-loader

    # Звук (ALSA - самый базовый уровень)
    alsa-lib

    # Библиотеки для оконной системы X11
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    xorg.libxshmfence

    # Сеть и безопасность
    openssl
    gnutls
    nspr # Часто требуется для сетевых библиотек

    # Другие общие зависимости
    stdenv.cc.cc
    zlib
    icu
  ];
}
