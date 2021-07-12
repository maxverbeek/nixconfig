{
  device = {
    screens = [
      { name = "eDP"; isPrimary = true; }
      { name = "HDMI-A-0"; } # external monitor, sometimes :)
    ];

    hasBattery = true;

    wifi = {
      enabled = true;
      interface = "wlp4s0";
    };

    withScreenLocker = true;
  };
}
