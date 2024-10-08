{
  battery = {
    format = "{icon}";
    format-charging = "";
    format-icons = [
      ""
      ""
      ""
      ""
      ""
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
    format = "";
    format-connected = " {device_alias}";
    format-connected-battery = " {device_alias} {device_battery_percentage}%";
    on-click = "blueberry";
    tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
    tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
    tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
    tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
  };
  clock = {
    calendar = {
      mode = "month";
    };
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
    format = "{index}";
    format-icons = {
      "1" = "";
      "2" = "";
      "3" = "";
      "4" = "";
      "5" = "";
      active = "";
      default = "";
    };
  };
  "niri/workspaces" = {
    format = "{name}";
    format-icons = {
      "1" = "";
      "2" = "";
      "3" = "";
      "4" = "";
      "5" = "";
      active = "";
      default = "";
    };
  };
  layer = "top";
  network = {
    format = " {ifname}";
    format-disconnected = "";
    format-icons = [
      ""
      ""
      ""
      ""
    ];
    format-wifi = "{icon} {essid}";
    max-length = 50;
    on-click = "nm-connection-editor";
    tooltip-format = "@ {ipaddr}\n {bandwidthDownBytes}  {bandwidthUpBytes}";
    tooltip-format-disconnected = "Disconnected";
    tooltip-format-wifi = "@ {ipaddr}\n {frequency}\n {bandwidthDownBytes}  {bandwidthUpBytes}";
  };
  tray = {
    icon-size = 15;
    spacing = 10;
  };
  wireplumber = {
    format = "{icon} {volume}%";
    format-icons = [
      ""
      ""
      ""
    ];
    format-muted = " {volume}%";
    max-volume = 150;
    on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    scroll-step = 5;
  };
}
