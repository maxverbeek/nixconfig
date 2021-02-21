{ pkgs, config, lib, ... }:
{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config =  rec {
      menu = "rofi -show drun";
      modifier = "Mod4";

      startup = [
        { command = "[ -f $HOME/.fehbg ] && $HOME/.fehbg"; always = true; notification = false; }
      ] ++ lib.optional (config.services.polybar.enable)
        { command = "systemctl --user restart polybar.service"; always = true; notification = false; };

      gaps = let size = 14; in {
        top = size;
        bottom = size;
        left = size;
        right = size;
        horizontal = size;
        vertical = size;

        smartBorders = true;
        smartGaps = true;
      };

      mod = modifer;
      keybindings = {
        "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty --working-directory $(${pkgs.xcwd}/bin/xcwd)";
        "${mod}+Shift+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${mod}+Space" = "exec ${menu}";
        "${mod}+Escape" = "reload";
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

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";
      };
    };
  };
}
