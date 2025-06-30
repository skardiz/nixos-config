# overlays/default.nix
#
# Точка входа в нашу мастерскую. Передает управление мастеру-бригадиру.
final: prev: import ../pkgs/_all.nix { pkgs = final; }
