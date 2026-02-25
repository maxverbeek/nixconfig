{ ... }:
{
  flake.modules.homeManager.waybar =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      modulesnix = {
        battery = {
          format = "{icon}";
          format-charging = "";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          interval = 5;
          max-length = 25;
          states = {
            critical = 15;
            warning = 30;
          };
          tooltip-format = "{capacity}% {time}";
          tooltip-format-charging = "{capacity}%  {timeTo}";
        };
        bluetooth = {
          format = "";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          on-click = "blueberry";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };
        clock = {
          calendar.mode = "month";
          format = "{:%a %d %b, %H:%M}";
          interval = 10;
          tooltip-format = "<span font='JetBrainsMono Nerd Font'>{calendar}</span>";
        };
        "custom/waybar-mpris" = {
          escape = true;
          exec = "waybar-mpris --position --autofocus";
          on-click = "waybar-mpris --send toggle";
          on-click-right = "waybar-mpris --send player-next";
          return-type = "json";
        };
        height = 34;
        "hyprland/workspaces" = {
          format = "{name}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            active = "";
            default = "";
          };
        };
        "niri/workspaces" = {
          format = "{index}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            active = "";
            default = "";
          };
        };
        layer = "top";
        network = {
          format = " {ifname}";
          format-disconnected = "";
          format-icons = [
            ""
            ""
            ""
            ""
          ];
          format-wifi = "{icon} {essid}";
          max-length = 50;
          on-click = "nm-connection-editor";
          tooltip-format = "@ {ipaddr}\n {bandwidthDownBytes}  {bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          tooltip-format-wifi = "@ {ipaddr}\n {frequency}\n {bandwidthDownBytes}  {bandwidthUpBytes}";
        };
        tray = {
          icon-size = 15;
          spacing = 10;
        };
        wireplumber = {
          format = "{icon} {volume}%";
          format-icons = [
            ""
            ""
            ""
          ];
          format-muted = " {volume}%";
          max-volume = 150;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 5;
        };
      };

      modulesfile = pkgs.writeText "modules.json" (builtins.toJSON modulesnix);

      waybarconfig = [
        {
          include = [ modulesfile ];
          modules-center = [ "mpris" ];
          modules-left = [
            "hyprland/workspaces"
            "niri/workspaces"
          ];
          modules-right = [
            "bluetooth"
            "battery"
            "network"
            "wireplumber"
            "tray"
            "clock"
          ];
        }
      ];

      styleCss = ''
        @define-color line-color #FFFFFF;
        @define-color text-normal rgba(255, 255, 255, 1);
        @define-color text-muted rgba(255, 255, 255, 0.5);
        @define-color bg-window rgba(0, 0, 0, 0.4);
        @define-color bg-darker alpha(@bg-window, 0.7);
        @define-color bluetooth-blue #0082FC;

        * {
          font-family: 'Noto Sans', 'Font Awesome 5 Pro', 'Font Awesome 5 Pro Solid';
          font-size: 14px;
        }

        #workspaces, #mpris, #bluetooth, #network, #wireplumber, #tray, #clock, #battery {
          padding: 0 10px;
        }

        #workspaces {
          padding-left: 0;
        }

        window#waybar {
          background: @bg-window;
          color: @text-normal;
        }

        #workspaces button {
          border-radius: 0;
          border: none;
          color: @text-normal;
          box-shadow: none;
        }

        #workspaces button.active {
          box-shadow: inset 0 -3px @line-color;
        }

        #workspaces button.empty {
          color: @text-muted;
        }

        #workspaces button:hover {
          background: alpha(@line-color, 0.2);
        }

        #network {
          background-color: @bg-darker;
        }

        #tray {
          background: @bg-darker;
        }

        #bluetooth.off, #bluetooth.disabled {
          color: @text-muted;
        }

        #bluetooth.on {
          color: @text-normal;
        }

        @keyframes pulse-bt {
          from { text-shadow: 0 0 2px @bluetooth-blue; }
          to { text-shadow: 0 0 6px @bluetooth-blue; }
        }

        #bluetooth.discovering {
          animation-name: pulse-bt;
          animation-duration: 1s;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
      '';
    in
    {
      programs.waybar = {
        enable = true;
        package = pkgs.unstable.waybar;
        settings = waybarconfig;
        style = pkgs.writeText "waybar-style.css" styleCss;

        systemd.enable = true;
        systemd.target = "hyprland-session.target";
      };

      systemd.user.services.waybar.Service.RestartSec = "3";

      home.packages = with pkgs; [
        unstable.waybar-mpris
        blueberry
        networkmanagerapplet
      ];
    };
}
