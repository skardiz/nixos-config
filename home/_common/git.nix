# home/_common/git.nix
{ ... }:
{
  programs.git.enable = true;
  services.ssh-agent.enable = true;
}
