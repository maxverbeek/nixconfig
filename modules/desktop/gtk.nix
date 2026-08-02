{ config, ... }:
{
  flake.modules.homeManager.personal =
    { pkgs, ... }:
    let
      theme = config.flake.lib.theme;
      catppuccin =
        variant:
        pkgs.catppuccin-gtk.override {
          accents = [ "mauve" ];
          size = "compact";
          inherit variant;
        };
    in
    {
      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus";
        };
        # Kanagawa has no light GTK theme, so GTK alone is Catppuccin.
        # Named in modules/desktop/theme.nix, not here.
        theme = {
          package = catppuccin theme.variants.dark.gtk.variant;
          name = theme.variants.dark.gtk.name;
        };
        # No GTK4 theme: libadwaita apps follow the color-scheme dconf key that
        # theme-toggle writes. Forcing a theme here would pin them to mocha.
        gtk4.theme = null;
      };

      # The light theme has to be installed too, or switching the dconf key
      # lands on a name GTK can't resolve and apps fall back to raw Adwaita.
      home.packages = [ (catppuccin theme.variants.light.gtk.variant) ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts.serif = [ "Noto Serif" ];
        defaultFonts.sansSerif = [ "Noto Sans" ];
      };
    };
}
