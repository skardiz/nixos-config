# /etc/nixos/modules/services.nix
# Конфигурация системных служб.
{ ... }:
{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
