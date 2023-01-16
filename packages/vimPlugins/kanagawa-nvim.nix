{ pkgs, lib, fetchFromGitHub, ... }:
pkgs.vimUtils.buildVimPluginFrom2Nix rec {
  pname = "kanagawa.nvim";

  # latest commit as of 2023-01-15
  version = "476eb2289d47d132ebacc1a4d459e3204866599b";

  src = fetchFromGitHub {
    owner = "rebelot";
    repo = "kanagawa.nvim";
    rev = "476eb2289d47d132ebacc1a4d459e3204866599b";
    hash = "sha256-KP3DgywCxMnKuB/Rg2VRFQpKULLKR5dX98j10Fm1IQ4=";
  };

  # see file in repo: $out/extras/alacritty_kanagawa.yml
  # dont know how to convert yml to nix, so i did it manually
  passthru.colors.alacritty = {
    primary = {
      background = "0x1f1f28";
      foreground = "0xdcd7ba";
    };

    normal = {
      black = "0x090618";
      red = "0xc34043";
      green = "0x76946a";
      yellow = "0xc0a36e";
      blue = "0x7e9cd8";
      magenta = "0x957fb8";
      cyan = "0x6a9589";
      white = "0xc8c093";
    };

    bright = {
      black = "0x727169";
      red = "0xe82424";
      green = "0x98bb6c";
      yellow = "0xe6c384";
      blue = "0x7fb4ca";
      magenta = "0x938aa9";
      cyan = "0x7aa89f";
      white = "0xdcd7ba";
    };

    selection = {
      background = "0x2d4f67";
      foreground = "0xc8c093";
    };

    indexed_colors = [
      {
        index = 16;
        color = "0xffa066";
      }
      {
        index = 17;
        color = "0xff5d62";
      }
    ];
  };

  # some colors i've assigned random names so that they can be used elsewhere
  passthru.colors.term = {
    normal = {
      black = "#090618";
      red = "#C34043";
      green = "#76946A";
      yellow = "#C0A36E";
      blue = "#7E9CD8";
      purple = "#957FB8";
      teal = "#6A9589";
      white = "#C8C093";
    };

    bright = {
      grey = " #727169";
      red = " #E82424";
      green = "#98BB6C";
      yellow = "#E6C384";
      blue = "#7FB4CA";
      purple = "#938AA9";
      teal = "#7AA89F";
      white = "#DCD7BA";
    };

    extended = {
      orange = "#FFA066";
      red = "#FF5D62";
      black = "#1F1F28";
      slate = "#2D4F67";
      lbrown = "#C8C093";
      blue = "#72A7BC";
      darker = "#15161E";
      background = "#1f1f28";
    };
  };
}
