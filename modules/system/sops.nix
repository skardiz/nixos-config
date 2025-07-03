# modules/system/sops.nix
{ inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
}
