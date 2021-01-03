{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;

    width = 750;
    lines = 13;
    font = "DejaVu Sans Mono 13";
    scrollbar = false;

    extraConfig = ''
      modi: "drun,run,window";
      separator-style: "solid";
      show-match: false;
    '';
  };
}
