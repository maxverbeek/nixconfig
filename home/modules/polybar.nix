{ pkgs, config, lib, ... }:
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

  bar = {
    width = "100%";
    height = "38";
    background = colors.background;
    foreground = colors.foreground;
    underline-color = colors.linecolor;
    underline-size = "3";

    font-0 = "Noto Sans:size=12;2";
    font-1 = "Font Awesome 5 Pro:size=12;3";
    font-2 = "Font Awesome 5 Brands:size=12;3";
    font-3 = "Font Awesome 5 Pro Solid:size=12:weight=bold;-2";

    modules-left = with lib;
      (optional (config.xsession.windowManager.bspwm.enable) "bspwm")
      ++ (optional (config.xsession.windowManager.i3.enable) "i3");

    modules-center = "xwindow";
    # modules-right is defined in the "all-bars" config per screen

    wm-restack = with config.xsession.windowManager;
      if i3.enable then "i3" else "bpswm";
  };

  # utility to filter a string on its alphanumeric characters
  alnumChars = lib.stringToCharacters
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJLKMNOPQRSTUVWXYZ1234567890";
  alnum = lib.stringAsChars (c: if builtins.elem c alnumChars then c else "");

  all-bars = builtins.listToAttrs (map
    # for each screen, generate a bar config
    (screen: {
      name = "bar/${alnum screen.name}";
      value = {
        monitor = screen.name;
      } // lib.optionalAttrs (screen.isPrimary) {

        tray-position = "right";
        tray-detached = "false";

        modules-right = with lib;
          concatStringsSep " "
          ((optional (config.device.wifi.enabled) "wireless")
            ++ [ "pulseaudio" ] ++ (optional config.device.hasBattery "battery")
            ++ [ "date" ]);

      } // lib.optionalAttrs (!screen.isPrimary) {

        # modules-right for non-primary screens (doesnt have wifi)
        modules-right = with lib;
          concatStringsSep " " ([ "pulseaudio" ]
            ++ (optional config.device.hasBattery "battery") ++ [ "date" ]);

      } // bar;
    }) config.device.screens);

  wm-module = {
    ws-icon-0 = "term;";
    ws-icon-1 = "web;";
    ws-icon-2 = "code;";
    ws-icon-3 = "gfx;";
    ws-icon-4 = "music;";
    ws-icon-5 = "slack;";
    ws-icon-6 = "bgstuff;";
    ws-icon-default = "";
    format = "<label-state> <label-mode>";

    label-focused = "%icon%";
    label-focused-background = "${colors.focusbackground}";
    label-focused-underline = "${colors.linecolor}";
    label-focused-padding = "4";

    label-occupied = "%icon%";
    label-occupied-padding = "4";

    label-urgent = "%icon%";
    label-urgent-padding = "4";

    label-empty = "%icon%";
    label-empty-foreground = "#66ffffff";
    label-empty-padding = "4";
  };

in {
  options = { modules.polybar.enable = lib.mkEnableOption "Enable Polybar"; };

  config = lib.mkIf config.modules.polybar.enable {

    assertions = with config.xsession.windowManager; [{
      assertion = bspwm.enable != i3.enable;
      message =
        "one of config.xsession.windowManager.{bspwm,i3} must be enabled";
    }];

    services.polybar = {
      enable = true;

      package = pkgs.polybar.override {
        pulseSupport = true;
        i3GapsSupport = config.xsession.windowManager.i3.enable;
      };

      config = all-bars // {
        # "bar/primary" = bar // {
        #   monitor = "DP-4";
        #   tray-position = "right";
        #   tray-detached = "false";
        # };

        # "bar/secondary" = bar // { monitor = "DP-2"; };

        "settings" = { screenchange-reload = "true"; };

        "module/bspwm" = wm-module // { type = "internal/bspwm"; };

        "module/i3" = wm-module // {
          type = "internal/i3";
          pin-workspaces = "true";
          strip-wsnumbers = "true";
          fuzzy-match = "true";
          index-sort = "true";

          label-unfocused = "%icon%";
          label-unfocused-padding = "4";

          label-visible = "%icon%";
          label-visible-padding = "4";
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
          label-muted = " %percentage%%";

          format-volume = "<ramp-volume> <label-volume>";
          format-muted = "<label-muted>";
          format-volume-padding = "3";
          format-muted-padding = "3";

          ramp-volume-0 = "";
          ramp-volume-1 = "";
          ramp-volume-2 = "";
          ramp-volume-3 = "";
        };
      } // lib.optionalAttrs (config.device.hasBattery) {

        "module/battery" = {
          type = "internal/battery";

          label-charging = "%percentage%";
          format-charging = "<animation-charging> <label-charging>%";
          format-charging-padding = "3";

          label-discharging = "%percentage%";
          format-discharging = "<ramp-capacity> <label-discharging>%";
          format-discharging-padding = "3";

          label-full = "%percentage%";
          format-full = "<ramp-capacity> <label-full>%";
          format-full-padding = "3";

          poll-interval = "10";
          full-at = "99";

          ramp-capacity-0 = "";
          ramp-capacity-1 = "";
          ramp-capacity-2 = "";
          ramp-capacity-3 = "";
          ramp-capacity-4 = "";

          animation-charging-0 = "";
          animation-charging-1 = "";
          animation-charging-2 = "";
          animation-charging-3 = "";
          animation-charging-4 = "";
          animation-charging-framerate = "750";
        };
      } // lib.optionalAttrs (config.device.wifi.enabled) {

        "module/wireless" = {
          type = "internal/network";
          interface = config.device.wifi.interface;
          interval = "3.0";

          # TODO: add scripts here, probably nm-applet or something
          format-connected =
            "%{A1:networkmanager_dmenu &:}%{A3:nm-connection-manager &:}<ramp-signal> <label-connected>%{A}%{A}";
          format-disconnected =
            "%{A1:networkmanager_dmenu &:}%{A3:nm-connection-manager &:}<label-disconnected>%{A}%{A}";
          format-connected-padding = "3";
          format-disconnected-padding = "3";
          format-connected-background = "${colors.focusbackground}";
          format-disconnected-background = "${colors.focusbackground}";

          label-connected = "%essid%";
          label-disconnected = "";

          ramp-signal-0 = "%{T4}%{T-}";
          ramp-signal-1 = "%{T4}%{T-}";
          ramp-signal-2 = "%{T4}%{T-}";
          ramp-signal-3 = "%{T4}%{T-}";
        };
      };

      script = builtins.concatStringsSep "\n"
        (map (s: "polybar ${alnum s.name} &") config.device.screens);
    };

  };
}
