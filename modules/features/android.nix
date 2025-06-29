# modules/features/android.nix
{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;
  systemd.services.waydroid-container.wantedBy = [ "multi-user.target" ];

  fileSystems."/var/lib/waydroid/data/media/0/Shared" = {
    device = "/home/shared/waydroid";
    fsType = "none";
    options = [ "bind" ];
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xorg.xwininfo
    xorg.xprop
  ];
}
