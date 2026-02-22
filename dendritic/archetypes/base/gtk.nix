{ ... }:
{
  # Home-manager: GTK theme, icons, fontconfig
  flake.modules.homeManager.gtk =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus";
        };
      };

      fonts.fontconfig = {
        enable = true;
        defaultFonts.serif = [ "Noto Serif" ];
        defaultFonts.sansSerif = [ "Noto Sans" ];
      };
    };
}
