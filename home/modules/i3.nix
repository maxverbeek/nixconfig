{ pkgs, config, lib, ... }:
let
  screens = config.device.screens;
  mod = "Mod4";
  reloadcmd = with lib; "reload"
    + optionalString (length screens > 1) "; exec ${switcherScript}/bin/fixscreens"
    + optionalString (config.services.polybar.enable) "; exec systemctl --user restart polybar.service;"
  ;

  screen = with builtins; x: (elemAt screens x).name;
  primscreen = with builtins; x: (elemAt screens x).isPrimary;

  # take care that this script isnt evaluated when there is only 1 screen configured
  # assume that only 1 screen is connected, otherwise this becomes much more complicated
  switcherScript = pkgs.writeScriptBin "fixscreens" ''
    ${pkgs.stdenv.shell}
    xrandr | grep -q "${screen 1} connected"
    ST=$?

    if [ $ST -eq 0 ]; then
      xrandr \
        --output ${screen 0} \
        --auto \
        ${lib.optionalString (primscreen 0) "--primary"} \
        --output ${screen 1} \
        --auto \
        ${lib.optionalString (primscreen 1) "--primary"} \
        --right-of ${screen 0}
    else
      xrandr --auto
    fi
  '';
in
{
  home.packages = with pkgs; with lib; [ feh rofi ] ++ optional (length screens > 1) switcherScript;

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config =  rec {
      menu = "rofi -show drun";
      modifier = mod;

      startup = [
        { command = "[ -f $HOME/.fehbg ] && $HOME/.fehbg"; always = true; notification = false; }
      ] ++ lib.optional (config.services.polybar.enable)
        { command = "systemctl --user restart polybar.service"; always = true; notification = false; };

      gaps = let size = 14; in {
        inner = size;

        smartBorders = "on";
        smartGaps = true;
      };

      assigns = {
        "2:web" = [{ class = "^Firefox$"; }];
        "3:code" = [
          { class = "^Code$"; } # vscode
          { class = "^jetbrains-"; }
        ];
        "5:gfx" = [{ class = "^Gimp"; }];
        "6:music" = [{ instance = "spotify"; }]; # broken, use for_window (see extraConfig)
        "7:slack" = [
          { class = "Slack"; }
          { class = "discord"; }
        ];
      };


      keybindings = {
        "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty --working-directory $(${pkgs.xcwd}/bin/xcwd)";
        "${mod}+Shift+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${mod}+space" = "exec ${menu}";
        "${mod}+Escape" = reloadcmd;
        "${mod}+Mod1+Escape" = "exit";
        "${mod}+w" = "kill";
        "${mod}+Control+l" = "exec ${config.services.screen-locker.lockCmd}";

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

        "${mod}+1" = ''workspace "1:term"'';
        "${mod}+2" = ''workspace "2:web"'';
        "${mod}+3" = ''workspace "3:code"'';
        "${mod}+4" = ''workspace "4:misc"'';
        "${mod}+5" = ''workspace "5:gfx"'';
        "${mod}+6" = ''workspace "6:music"'';
        "${mod}+7" = ''workspace "7:slack"'';
        "${mod}+8" = ''workspace "8:misc"'';
        "${mod}+9" = ''workspace "9:bgstuff"'';
        "${mod}+0" = ''workspace "0:misc"'';

        "${mod}+Shift+1" = ''move container to workspace "1:term"'';
        "${mod}+Shift+2" = ''move container to workspace "2:web"'';
        "${mod}+Shift+3" = ''move container to workspace "3:code"'';
        "${mod}+Shift+4" = ''move container to workspace "4:misc"'';
        "${mod}+Shift+5" = ''move container to workspace "5:gfx"'';
        "${mod}+Shift+6" = ''move container to workspace "6:music"'';
        "${mod}+Shift+7" = ''move container to workspace "7:slack"'';
        "${mod}+Shift+8" = ''move container to workspace "8:misc"'';
        "${mod}+Shift+9" = ''move container to workspace "9:bgstuff"'';
        "${mod}+Shift+0" = ''move container to workspace "0:misc"'';
      };

      bars = [];
    };

    extraConfig = with builtins; let
      # assume at most 2 screens for now
      # specifying multiple outputs means the first one will
      # be picked when available.
      primary = screen 0;
      secondary = if length screens > 1 then screen 1 else "";
    in
    ''
      workspace "1:term" output ${primary} ${secondary}
      workspace "2:web" output ${primary} ${secondary}
      workspace "3:code" output ${primary} ${secondary}
      workspace "4:misc" output ${primary} ${secondary}
      workspace "5:gfx" output ${primary} ${secondary}
      workspace "6:music" output ${secondary} ${primary}
      workspace "7:slack" output ${secondary} ${primary}
      workspace "8:misc" output ${secondary} ${primary}
      workspace "9:bgstuff" output ${secondary} ${primary}
      workspace "0:misc" output ${secondary} ${primary}

      for_window [class="Spotify"] move to workspace "6:music"
    '';

  };
}
