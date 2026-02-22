{ ... }:
{
  # Home-manager: foot + alacritty terminal configuration with kanagawa colors
  flake.modules.homeManager.terminal =
    { pkgs, config, ... }:
    {
      programs.foot = {
        enable = true;
        settings.colors = pkgs.custom.kanagawa-nvim.colors.foot;
        settings.main.font = "JetBrainsMono Nerd Font:size=${toString config.device.termFontSize}";
      };

      programs.alacritty = {
        enable = true;
        settings = {
          font.size = config.device.termFontSize;
          colors = pkgs.custom.kanagawa-nvim.colors.alacritty;
        };
      };
    };
}
