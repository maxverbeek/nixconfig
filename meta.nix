{ my }:
{
  repoRoot = "/home/max/nixconfig";

  # The huurhunter monitor container's egress Floating IPs, kept in the private
  # huurhunter repo. Empty means plain NAT out of the VPS's main IP.
  huurhunter.egressFips = my.sources.huurhunter.egressFips or [ ];

  # Light/dark theme. Every themed line in the repo reads `my.meta.theme`, so
  # grepping `theme.` lists all consumers.
  theme = {
    # Runtime state, written by theme-toggle and watched by barbell. Outside the
    # store: a runtime toggle cannot be a function of the config.
    statePath = "theme.json";

    # foot reads its config at startup only and cannot watch theme.json, so
    # theme-toggle writes `initial-color-theme` here and foot.ini includes it.
    footThemeIni = ".config/foot/theme.ini";

    variants = {
      dark = {
        scheme = "prefer-dark";
        # nvim chooses its colorscheme from `background`, which it detects from
        # the terminal itself; setting vim.o.background from here would make it
        # drop that autodetection.
        nvim.colorscheme = "kanagawa";
        gtk = {
          palette = "kanagawa";
          themeName = "adw-gtk3-dark";
        };
      };

      light = {
        scheme = "prefer-light";
        nvim.colorscheme = "catppuccin-latte";
        gtk = {
          palette = "latte";
          themeName = "adw-gtk3";
        };
      };
    };
  };
}
