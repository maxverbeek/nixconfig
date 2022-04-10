{ pkgs, config, lib, ... }:
with lib; {
  options = { modules.alacritty.enable = mkEnableOption "Enable alacritty"; };

  config = {
    programs.alacritty = {
      enable = true;
      settings = {
        font.size = config.device.termFontSize;
        colors = pkgs.custom.kanagawa-nvim.colors.alacritty;
      };
    };
  };
}
