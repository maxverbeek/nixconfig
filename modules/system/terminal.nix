{ config, ... }:
let
  fontsize = 12;
  theme = config.flake.lib.theme;
in
{
  flake.modules.homeManager.headful =
    { pkgs, lib, ... }:
    {
      programs.foot = {
        enable = true;
        # Both palettes live in the config at once; foot switches between them
        # on SIGUSR1 (dark) / SIGUSR2 (light) with no restart and no rewrite.
        # Switching also makes foot notify subscribed apps (private mode 2031),
        # which is how nvim re-themes itself -- see modules/desktop/theme.nix.
        settings.colors-dark = pkgs.custom.kanagawa-nvim.colors.foot;
        # Catppuccin Latte, transcribed from catppuccin/foot
        # themes/static/catppuccin-latte.ini. Same shape as the kanagawa sets.
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
        # terminals start on the active variant. See modules/desktop/theme.nix.
        settings.main.include = "~/${theme.footThemeIni}";
      };

      # A missing include is FATAL to foot, so the file must exist before the
      # first toggle ever runs. Seed once; theme-toggle owns it from then on.
      home.activation.seedFootThemeIni = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ini="$HOME/${theme.footThemeIni}"
        if [ ! -f "$ini" ]; then
          run mkdir -p "''${ini%/*}"
          run sh -c "printf '[main]\ninitial-color-theme=dark\n' > '$ini'"
        fi
      '';

      # Live foots switch palette on the signal (and notify apps via mode 2031,
      # which is how nvim re-themes). Future foots read the rewritten include.
      theme.onSwitch.foot =
        { name, ... }:
        ''
          ${pkgs.procps}/bin/pkill -${if name == "dark" then "USR1" else "USR2"} foot || true
          printf '[main]\ninitial-color-theme=%s\n' ${name} > "$HOME/${theme.footThemeIni}"
        '';

      # make it so that cd-ing in zsh will send escape sequences to the terminal emulator (foot) so that it is aware
      # from which cwd to spawn new terminals.
      programs.zsh.initContent = ''
        function osc7-pwd() {
            emulate -L zsh # also sets localoptions for us
            setopt extendedglob
            local LC_ALL=C
            printf '\e]7;file://%s%s\e\' $HOST ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
        }

        function chpwd-osc7-pwd() {
            (( ZSH_SUBSHELL )) || osc7-pwd
        }
        add-zsh-hook -Uz chpwd chpwd-osc7-pwd
      '';

      programs.alacritty = {
        enable = true;
        settings = {
          font.size = fontsize;
          colors = pkgs.custom.kanagawa-nvim.colors.alacritty;
        };
      };

      programs.man.enable = true;

      home.packages = [
        pkgs.self.not
      ];
    };
}
