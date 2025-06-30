# pkgs/_all.nix (Правильный вариант)
{ pkgs }: {
  dpitunnel = pkgs.callPackage ./dpitunnel { };
  thorium-browser = pkgs.callPackage ./thorium-browser { };
}
