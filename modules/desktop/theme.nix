{ ... }:
{
  # Single source of truth for the light/dark theme.
  #
  # Two kinds of thing live here, because apps come in two kinds:
  #
  #   colors.*  -- raw hex, for apps that only understand colours
  #                (rofi, wayscriber, barbell, foot, alacritty)
  #   nvim/gtk  -- *identity*: colorscheme and palette names. Consumers map
  #                these to their own theme mechanism.
  #
  # Consumers read `flake.lib.theme` and nothing else, so every themed line in
  # this repo contains the string `theme.` -- grep for it to find them all.
  #
  # CAVEAT: `colors` and `nvim`/`gtk` are two representations of the same
  # theme that nothing forces to agree. A Lua colorscheme isn't derivable from
  # hex, so keeping them in sync is manual. Swapping themes means changing
  # both halves.
  flake.lib.theme =
    let
      # Runtime state: which variant is active right now. theme-toggle writes
      # it, barbell watches it. Outside the store on purpose -- a runtime
      # toggle can't be a function of the config alone.
      statePath = "theme.json";

      # foot can't watch theme.json, and only reads config at startup -- so a
      # new terminal in light mode would start dark. theme-toggle writes
      # `initial-color-theme` here and foot.ini includes it. $HOME-relative
      # (foot requires absolute or ~/ include paths, so no XDG_RUNTIME_DIR),
      # which also means the variant survives reboots, matching dconf.
      footThemeIni = ".config/foot/theme.ini";
    in
    {
      inherit statePath footThemeIni;

      # Hex "#RRGGBB" -> { r, g, b } in 0-255. Lives here rather than in any
      # one consumer because it's a colour concern, not an app concern.
      hexToRgb =
        hex:
        let
          h = builtins.substring 1 6 hex; # strip leading #
          hexDigit =
            c:
            let
              digits = {
                "0" = 0;
                "1" = 1;
                "2" = 2;
                "3" = 3;
                "4" = 4;
                "5" = 5;
                "6" = 6;
                "7" = 7;
                "8" = 8;
                "9" = 9;
                "a" = 10;
                "b" = 11;
                "c" = 12;
                "d" = 13;
                "e" = 14;
                "f" = 15;
                "A" = 10;
                "B" = 11;
                "C" = 12;
                "D" = 13;
                "E" = 14;
                "F" = 15;
              };
            in
            digits.${c};
          byte = hi: lo: (hexDigit hi) * 16 + (hexDigit lo);
        in
        {
          r = byte (builtins.substring 0 1 h) (builtins.substring 1 1 h);
          g = byte (builtins.substring 2 1 h) (builtins.substring 3 1 h);
          b = byte (builtins.substring 4 1 h) (builtins.substring 5 1 h);
        };

      variants = {
        dark = {
          # What the desktop calls this, for dconf/portal consumers.
          scheme = "prefer-dark";

          # Neovim needs no colours from us: init.lua maps
          # background=dark -> kanagawa (wave), background=light ->
          # catppuccin-latte, and nvim sets `background` itself from the
          # terminal (mode 2031). Nothing here should ever set
          # vim.o.background -- doing so makes nvim delete its own
          # auto-detect autocmd. See theme-toggle.nix.
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
