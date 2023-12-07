{ pkgs, config, lib, ... }:
with lib; {
  options = { modules.alacritty.enable = mkEnableOption "Enable alacritty"; };

  config = {
    programs.foot = {
      enable = true;
      settings.colors = pkgs.custom.kanagawa-nvim.colors.foot;
      settings.main.font = "JetBrainsMono Nerd Font:size=9";
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
