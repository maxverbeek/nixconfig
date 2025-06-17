{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    modules.rstudio.enable = lib.mkEnableOption "Enable RStudio";
  };
  config = lib.mkIf config.modules.rstudio.enable {
    # home.packages = with pkgs; [
    #   (rstudioWrapper.override {
    #     packages = with rPackages; [
    #       haven
    #       rms
    #       Rcpp
    #       caret
    #       labelled
    #       tidyverse
    #       ggplot2
    #       markdown
    #     ];
    #   })
    # ];
    home.packages = [ pkgs.rstudio ];
  };
}
