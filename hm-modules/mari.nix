{ pkgs, ... }:
{
  # Индивидуальные пакеты для mari
  home.packages = with pkgs; [ google-chrome zoom-us ];
}
