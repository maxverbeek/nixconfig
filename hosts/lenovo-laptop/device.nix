{
  device = {
    screens = [
      {
        name = "eDP-1";
        isPrimary = true;
      }
      { name = "HDMI-1"; } # external monitor, sometimes :)
    ];

    hasBattery = true;
    hasBrightness = true;

    wifi = {
      enabled = true;
      interface = "wlp4s0";
    };

    hyprland.enable = true;

    withScreenLocker = false;
    termFontSize = 12;
  };
}
