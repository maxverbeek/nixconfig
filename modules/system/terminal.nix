{ ... }:
let
  fontsize = 12;
in
{
  flake.modules.homeManager.headful =
    { pkgs, config, ... }:
    {
      programs.foot = {
        enable = true;
        # Both palettes live in the config at once; foot switches between them
        # on SIGUSR1 (dark) / SIGUSR2 (light) with no restart and no rewrite.
        # Switching also makes foot notify subscribed apps (private mode 2031),
        # which is how nvim re-themes itself -- see modules/desktop/theme.nix.
        settings.colors-dark = pkgs.custom.kanagawa-nvim.colors.foot;
        settings.colors-light = pkgs.custom.kanagawa-nvim.colors.lotus.foot;
        settings.main.font = "JetBrainsMono Nerd Font:size=${toString fontsize}";
      };

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
