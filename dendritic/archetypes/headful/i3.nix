{ ... }:
{
  # Home-manager: i3 window manager (legacy X11)
  flake.modules.homeManager.i3 =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      screens = config.device.screens;
      screen = with builtins; x: (elemAt screens x).name;
      primscreen = with builtins; x: (elemAt screens x).isPrimary;

      fixscreens = pkgs.writeScriptBin "fixscreens" ''
        #!${pkgs.stdenv.shell}
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

        $HOME/.fehbg
      '';

      autorandrScript = pkgs.writeScriptBin "fixscreensautorandr" ''
        #!${pkgs.stdenv.shell}
        autorandr -c
        ~/.fehbg
        systemctl --user restart polybar.service
      '';

      mirror = pkgs.writeScriptBin "mirror" ''
        #!${pkgs.stdenv.shell}
        xrandr | grep -q "${screen 1} connected"
        ST=$?

        if [ $ST -eq 0 ]; then
          xrandr \
            --output ${screen 0} \
            ${lib.optionalString (primscreen 0) "--primary"} \
            ${lib.optionalString (primscreen 1) "--same-as ${screen 1}"} \
            --auto \
            --output ${screen 1} \
            ${lib.optionalString (primscreen 1) "--primary"} \
            ${lib.optionalString (primscreen 0) "--same-as ${screen 0}"} \
            --auto
        else
          xrandr --auto
        fi

        $HOME/.fehbg
      '';

      mod = "Mod4";

      reloadcmd =
        let
          reload = "reload";
          fixscreensCmd = "exec ${autorandrScript}/bin/fixscreensautorandr";
          polybar = "exec systemctl --user restart polybar.service";
          commands = [
            reload
          ]
          ++ lib.optional (builtins.length screens > 1) fixscreensCmd;
        in
        lib.concatStringsSep "; " commands;
    in
    {
      home.packages = [
        pkgs.feh
        fixscreens
        mirror
      ];

      xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3;
        config = rec {
          menu = "rofi -show-icons -show drun";
          modifier = mod;

          startup = [
            {
              command = "[ -f $HOME/.fehbg ] && $HOME/.fehbg";
              always = true;
              notification = false;
            }
          ];

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
              { class = "^Code$"; }
              { class = "^jetbrains-"; }
            ];
            "4:gfx" = [ { class = "^Gimp"; } ];
            "5:music" = [ { instance = "spotify"; } ];
            "6:slack" = [
              { class = "Slack"; }
              { class = "discord"; }
            ];
          };

          keybindings = {
            "${mod}+Return" =
              "exec ${pkgs.alacritty}/bin/alacritty --working-directory $(${pkgs.xcwd}/bin/xcwd)";
            "${mod}+Shift+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
            "${mod}+space" = "exec ${menu}";
            "${mod}+Escape" = reloadcmd;
            "${mod}+Mod1+Escape" = "exit";
            "${mod}+w" = "kill";

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
          // lib.optionalAttrs config.device.hasBrightness {
            "XF86MonBrightnessUp" = "exec light -A 10";
            "XF86MonBrightnessDown" = "exec light -U 10";
          };

          bars = [ ];
        };

        extraConfig =
          let
            primary = screen 0;
            secondary = if builtins.length screens > 1 then screen 1 else "";
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
