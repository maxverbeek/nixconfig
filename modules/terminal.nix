{ ... }:
let
  fontsize = 12;
in
{
  flake.modules.homeManager.terminal =
    { pkgs, config, ... }:
    {
      programs.foot = {
        enable = true;
        settings.colors = pkgs.custom.kanagawa-nvim.colors.foot;
        settings.main.font = "JetBrainsMono Nerd Font:size=${toString fontsize}";
      };

      programs.alacritty = {
        enable = true;
        settings = {
          font.size = fontsize;
          colors = pkgs.custom.kanagawa-nvim.colors.alacritty;
        };
      };

      programs.man.enable = true;
    };
}
