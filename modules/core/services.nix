# modules/services.nix
{ ... }:

{
  services.pipewire = { enable = true; pulse.enable = true; };
}
