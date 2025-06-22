# /home/alex/nixos-config/hm-modules/alex/git.nix
{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Alex";
    userEmail = "skardizone@gmail.com";
  };
  services.ssh-agent.enable = true;
}
