{ config, pkgs, lib, ... }: {

  imports = [ ./sxhkd.nix ];

  options = { modules.bspwm.enable = lib.mkEnableOption "Enable bspwm"; };

  config = lib.mkIf config.modules.bspwm.enable {

    modules.sxhkd.enable = true;

    # Ensure feh installed for a background
    home.packages = with pkgs; [ feh rofi ];

    xsession.windowManager.bspwm = {
      enable = true;

      # Restart polybar after bspwm started. Ideally it should start after bspwm
      # starts, but the xsession systemd target must be started before the
      # windowmanager, and starting polybar before bspwm causes weird shit to
      # happen.
      startupPrograms = [ "[ -f $HOME/.fehbg ] && $HOME/.fehbg" ]
        ++ lib.optional (config.services.polybar.enable)
        "systemctl --user restart polybar.service";

      settings = {
        border_width = 4;
        window_gap = 14;
        single_monocle = true;
        split_ratio = 0.5;
        borderless_monocle = true;
        gapless_monocle = true;

        # todo
        normal_border_color = "#FFFFFF";
        focused_border_color = "#FFFFFF";
        urgent_border_color = "#FFFFFF";
        presel_feedback_color = "#FFFFFF";
      };

      # left, 2560x1440
      monitors."DP-4" = [ "term" "web" "code" "misc" "gfx" ];

      # right, 1920x1080
      monitors."DP-2" = [ "music" "preview" "slack" "bgstuff" "whatever" ];

      # extraConfig = ''
      #   bspc monitor DP-4 -n 1 term web code misc gfx
      #   bspc monitor DP-2 -n 2 music preview whatever bgstuff ihavetoomuchspace
      # '';

      rules = {
        "Gimp" = {
          desktop = "gfx";
          state = "floating";
          follow = true;
        };

        "Chromium-browser".desktop = "web";
        "Firefox".desktop = "web";

        "spotify".desktop = "music";
        "slack".desktop = "slack";
        "Slack".desktop = "slack";

        "mplayer2".state = "floating";
        "Kupfer.py".focus = true;
        "Screenkey".manage = false;
        "Nm-connection-editor".state = "floating";
        "Zathura".state = "tiled";
      };
    };

  };
}
