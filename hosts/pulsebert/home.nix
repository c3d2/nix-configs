{ pkgs, ... }:

{
  home.packages = with pkgs; [
    htop
    fortune
    ddate
    mpv
    ncmpcpp
    schedtool
    screen
    tmux
    pulsemixer
  ];
}
