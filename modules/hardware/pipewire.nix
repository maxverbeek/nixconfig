{
  nixos.hardware.pipewire =
    { lib, ... }:
    {
      boot.kernelModules = [ "v4l2loopback" ];

      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        jack.enable = true;
        wireplumber = {
          enable = true;
          extraConfig.bluetoothEnhancements = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              # Don't set bluez5.roles. Narrowing it broke profile selection:
              # devices bond, then drop with "a2dp-sink profile connect failed:
              # Protocol not available". The default is wider anyway.
            };
          };

          # Already wireplumber's defaults, spelled out because this is the
          # pair that gets blamed when a headset mic goes missing: opening the
          # mic drops the headset to HFP (Bluetooth can't do stereo + mic at
          # once), and mSBC above makes that fallback wideband.
          extraConfig.autoswitchToHeadset = {
            "wireplumber.settings" = {
              "bluetooth.autoswitch-to-headset-profile" = true;
              "bluetooth.use-persistent-storage" = true;
            };
          };
        };
      };

      services.pulseaudio.enable = lib.mkForce false;

      users.users.max.extraGroups = [ "audio" ];
    };
}
