{
  wrappers.configured.foot =
    { my, wlib, ... }:
    let
      fontsize = 12;
    in
    {
      imports = [ wlib.wrapperModules.foot ];

      # Both palettes live in the config at once; foot switches between them on
      # SIGUSR1 (dark) / SIGUSR2 (light) with no restart and no rewrite, and
      # notifies subscribed apps (mode 2031), which is how nvim re-themes.
      settings.colors-dark = my.pkgs.kanagawa-nvim.colors.foot;
      # Catppuccin Latte, transcribed from catppuccin/foot
      # themes/static/catppuccin-latte.ini.
      settings.colors-light = {
        foreground = "4c4f69";
        background = "eff1f5";

        selection-foreground = "4c4f69";
        selection-background = "ccced7";

        regular0 = "5c5f77";
        regular1 = "d20f39";
        regular2 = "40a02b";
        regular3 = "df8e1d";
        regular4 = "1e66f5";
        regular5 = "ea76cb";
        regular6 = "179299";
        regular7 = "acb0be";

        bright0 = "6c6f85";
        bright1 = "d20f39";
        bright2 = "40a02b";
        bright3 = "df8e1d";
        bright4 = "1e66f5";
        bright5 = "ea76cb";
        bright6 = "179299";
        bright7 = "bcc0cc";

        "16" = "fe640b";
        "17" = "dc8a78";
      };
      settings.main.font = "JetBrainsMono Nerd Font:size=${toString fontsize}";
      # Mutable, theme-toggle-owned: carries initial-color-theme so new
      # terminals start on the active variant.
      settings.main.include = "~/${my.meta.theme.footThemeIni}";
    };
}
