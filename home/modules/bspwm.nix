{ pkgs, ... }:

{
  config = {
    xsession.windowManager.bspwm = {
      enable = true;

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
      monitors."DP-2" = [ "music" "preview" "slack" "bgstuff" "whatever"];

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
        "firefox".desktop = "web";

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
    
    services.sxhkd = {
      enable = true;

      keybindings = {
        #
        # wm independent hotkeys
        #

        # terminal emulator in current workingdir
        "super + Return" = "${pkgs.alacritty}/bin/alacritty";

        # terminal in current home
        "super + shift + Return" = "alacritty";

        # program launcher
        "super + space" = "rofi -show drun";

        # make sxhkd reload its configuration files:
        "super + Escape" = "pkill -USR1 -x sxhkd";

        # audio control
        "XF86AudioMute" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";

        "XF86AudioRaiseVolume" = "pactl set-sink-mute @DEFAULT_SINK@ 0; pactl set-sink-volume @DEFAULT_SINK@ +5%";

        "XF86AudioLowerVolume" = "pactl set-sink-mute @DEFAULT_SINK@ 0; pactl set-sink-volume @DEFAULT_SINK@ -5%";

        # screenshots
        # "Print" = "maim -s -d 0.2 -u /tmp/screenshot.png && xclip -selection c -t image/png < /tmp/screenshot.png";

        # "shift + Print" = "maim /tmp/screenshot.png && xclip -selection c -t image/png < /tmp/screenshot.png";

        # Lock screen
        # "XF86ScreenSaver" = "lock";

        # bspwm hotkeys
        #
        "super + {_,shift} + r" = "bspc node @/ -C {forward,backward}";

        "super + {_,alt} + b" = "bspc node @{parent,/} -B";

        # quit bspwm normally
        "super + alt + Escape" = "bspc quit";

        # close and kill
        "super + {_,shift + }w" = "bspc node -{c,k}";

        # alternate between the tiled and monocle layout
        "super + m" = "bspc desktop -l next";

        # send the newest marked node to the newest preselected node
        "super + y" = "bspc node newest.marked.local -n newest.!automatic.local";

        # swap the current node and the biggest node
        "super + g" = "bspc node -s biggest.local";

        #
        # state/flags
        #

        # set the window state
        "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";

        # set the node flags
        "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}";

        #
        # focus/swap
        #

        # focus the node in the given direction
        "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";

        # focus the node for the given path jump
        "super + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}";

        # focus the next/previous node in the current desktop
        "super + {_,shift + }c" = "bspc node -f {next,prev}.local";

        # focus the next/previous desktop in the current monitor
        "super + {Left,Right}" = "bspc desktop -f {prev,next}.local";
        "super + bracket{left,right}" = "bspc desktop -f {prev,next}.local";

        # focus the last node/desktop
        "super + {grave,Tab}" = "bspc {node,desktop} -f last";

        # focus the older or newer node in the focus history
        "super + {o,i}" = "bspc wm -h off; bspc node {older,newer} -f; bspc wm -h on";

        # focus or send to the given desktop
        "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";

        #
        # preselect
        #

        # preselect the direction
        "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}";

        # preselect the ratio
        "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}";

        # cancel the preselection for the focused node
        "super + ctrl + space" = "bspc node -p cancel";

        # cancel the preselection for the focused desktop
        "super + ctrl + shift + space" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel";

        #
        # move/resize
        #

        # expand a window to the left outwards (or right inwards)
        "super + alt + h" = "bspc node -z left -30 0 || bspc node -z right -30 0";

        # expand a window bottom outwards (or top inwards)
        "super + alt + j" = "bspc node -z bottom 0 30 || bspc node -z top 0 30";

        # expand a window top outwards (or bottom inwards)
        "super + alt + k" = "bspc node -z top 0 -30 || bspc node -z bottom 0 -30 ";

        # expand a window right outwards (or left inwards)
        "super + alt + l" = "bspc node -z right 30 0 || bspc node -z left 30 0";


        # contract a window by moving one of its side inward
        "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -30 0,top 0 30,bottom 0 -30,left 30 0}";

        # move a floating window
        "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";
      };
    };
  };
}
