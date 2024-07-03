{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.modules.i3;
  screens = config.device.screens;
  scripts = import ./scripts.nix { inherit config pkgs lib; };

  # helpers to quickly get screen attributes
  screen = with builtins; x: (elemAt screens x).name;
  primscreen = with builtins; x: (elemAt screens x).isPrimary;

  # reload i3 config, re-apply xrandr scripts to expand screens, restart polybar
  reloadcmd =
    with lib;
    let
      reload = "reload";
      fixscreens = "exec ${scripts.autorandr}/bin/fixscreensautorandr";
      polybar = "exec systemctl --user restart polybar.service";

      commands = [
        reload
      ] ++ optional (length screens > 1) fixscreens ++ optional (config.services.polybar.enable) polybar;
    in
    concatStringsSep "; " commands;

  mod = cfg.mod;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      feh
      scripts.fixscreens
      scripts.mirror
    ];
    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      config = rec {
        menu = "rofi -show-icons -show drun";
        modifier = cfg.mod;

        startup =
          [
            {
              command = "[ -f $HOME/.fehbg ] && $HOME/.fehbg";
              always = true;
              notification = false;
            }
          ]
          ++ lib.optional (config.services.polybar.enable) {
            command = "systemctl --user restart polybar.service";
            always = true;
            notification = false;
          };

        gaps = {
          inner = 14;
          smartBorders = "on";
          smartGaps = true;
        };

        assigns = {
          "1:web" = [
            { class = "^Firefox$"; }
            { class = "^Chromium-browser$"; }
          ];
          "2:code" = [
            { class = "^Code$"; } # vscode
            { class = "^jetbrains-"; }
          ];
          "4:gfx" = [ { class = "^Gimp"; } ];
          "5:music" = [ { instance = "spotify"; } ]; # broken, use for_window (see extraConfig)
          "6:slack" = [
            { class = "Slack"; }
            { class = "discord"; }
          ];
        };

        keybindings =
          {
            "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty --working-directory $(${pkgs.xcwd}/bin/xcwd)";
            "${mod}+Shift+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
            "${mod}+space" = "exec ${menu}";
            "${mod}+Escape" = reloadcmd;
            "${mod}+Mod1+Escape" = "exit";
            "${mod}+w" = "kill";
            "${mod}+Control+l" = "exec ${config.services.my-screen-locker.lockCmd}";

            "Print" = "exec ${pkgs.gnome.gnome-screenshot}/bin/gnome-screenshot -c -a";
            "Print+Shift" = "exec ${pkgs.gnome.gnome-screenshot}/bin/gnome-screenshot -c -w";
            "${mod}+Print" = "exec ${pkgs.gnome.gnome-screenshot}/bin/gnome-screenshot --interactive";

            "${mod}+t" = "floating toggle";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+v" = "split toggle";

            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";

            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";

            "${mod}+Mod1+h" = "resize shrink width 10px or 10 ppt";
            "${mod}+Mod1+j" = "resize shrink height 10px or 10 ppt";
            "${mod}+Mod1+k" = "resize grow height 10px or 10 ppt";
            "${mod}+Mod1+l" = "resize grow width 10px or 10 ppt";

            "${mod}+1" = ''workspace "0:term"'';
            "${mod}+2" = ''workspace "1:web"'';
            "${mod}+3" = ''workspace "2:code"'';
            "${mod}+4" = ''workspace "3:misc"'';
            "${mod}+5" = ''workspace "4:gfx"'';
            "${mod}+6" = ''workspace "5:music"'';
            "${mod}+7" = ''workspace "6:slack"'';
            "${mod}+8" = ''workspace "7:misc"'';
            "${mod}+9" = ''workspace "8:bgstuff"'';
            "${mod}+0" = ''workspace "9:misc"'';

            "${mod}+Shift+1" = ''move container to workspace "0:term"'';
            "${mod}+Shift+2" = ''move container to workspace "1:web"'';
            "${mod}+Shift+3" = ''move container to workspace "2:code"'';
            "${mod}+Shift+4" = ''move container to workspace "3:misc"'';
            "${mod}+Shift+5" = ''move container to workspace "4:gfx"'';
            "${mod}+Shift+6" = ''move container to workspace "5:music"'';
            "${mod}+Shift+7" = ''move container to workspace "6:slack"'';
            "${mod}+Shift+8" = ''move container to workspace "7:misc"'';
            "${mod}+Shift+9" = ''move container to workspace "8:bgstuff"'';
            "${mod}+Shift+0" = ''move container to workspace "9:misc"'';
          }
          // lib.optionalAttrs (config.device.hasBrightness) {
            "XF86MonBrightnessUp" = "exec light -A 10";
            "XF86MonBrightnessDown" = "exec light -U 10";
          };

        bars = [ ];
      };

      extraConfig =
        with builtins;
        let
          # assume at most 2 screens for now
          # specifying multiple outputs means the first one will
          # be picked when available.
          primary = screen 0;
          secondary = if length screens > 1 then screen 1 else "";
        in
        ''
          workspace "0:term" output ${primary} ${secondary}
          workspace "1:web" output ${primary} ${secondary}
          workspace "2:code" output ${primary} ${secondary}
          workspace "3:misc" output ${primary} ${secondary}
          workspace "4:gfx" output ${primary} ${secondary}
          workspace "5:music" output ${secondary} ${primary}
          workspace "6:slack" output ${secondary} ${primary}
          workspace "7:misc" output ${secondary} ${primary}
          workspace "8:bgstuff" output ${secondary} ${primary}
          workspace "9:misc" output ${secondary} ${primary}

          for_window [class="Spotify"] move to workspace "5:music"
        '';
    };
  };
}
