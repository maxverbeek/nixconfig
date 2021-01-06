{ pkgs, ... }:
let

  colors = rec {
    white = "#FFFFFF";
    black = "#000000";

    foreground = white;
    background = "#55000000";
    linecolor = foreground;
    focusbackground = "#88000000";
    focuslinecolor = foreground;
  };

in
{
  services.polybar = {
    enable = true;

    config = {
      "bar/main" = {
        width = "100%";
        height = "38";
        pin-workspaces = "false";
        background = colors.background;
        foreground = colors.foreground;
        underline-color = colors.linecolor;
        underline-size = "3";

        font-0 = "Noto Sans:size=12;2";
        font-1 = "Font Awesome 5 Pro:size=12;3";
        font-2 = "Font Awesome 5 Brands:size=12;1";
        font-3 = "Font Awesome 5 Pro Solid:size=12:weight=bold;-2";

        modules-left = "bspwm";
        modules-center = "xwindow";
        modules-right = "pulseaudio date";

        wm-restack = "bspwm";

        tray-positioned = "right";
        tray-detached = "false";
      };

      "module/bspwm" = {
        type = "internal/bspwm";

        ws-icon-0 = "term;";
        ws-icon-1 = "web;";
        ws-icon-2 = "code;";
        ws-icon-3 = "gfx;";
        ws-icon-default = "";
        format = "<label-state> <label-mode>";

        label-focused = "%icon%";
        label-focused-background = "${colors.focusbackground}";
        label-focused-underline  = "${colors.linecolor}";
        label-focused-padding = "4";

        label-occupied = "%icon%";
        label-occupied-padding = "4";

        label-urgent = "%icon%";
        label-urgent-padding = "4";

        label-empty = "%icon%";
        label-empty-foreground = "#66ffffff";
        label-empty-padding = "4";
      };

      "module/xwindow" = {
        type = "internal/xwindow";

        label = "%title:0:64:...%";
        label-padding = "4";
      };

      "module/date" = {
        type = "internal/date";

        date = "%a %d %b";
        time = "%H:%M";

        label = "%date%, %time%";
        format = " <label>";
        format-padding = "3";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";

        label-volume = "%percentage%%";
        label-muted  = " %percentage%%";

        format-volume = "<ramp-volume> <label-volume>";
        format-muted  = "<label-muted>";
        format-volume-padding = "3";
        format-muted-padding = "3";

        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";
        ramp-volume-3 = "";
      };
    };

    script = ''
      polybar main &
    '';
  };

}
