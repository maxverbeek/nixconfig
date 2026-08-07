{ ... }:
{
  flake.modules.nixos.multimedia =
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
              # Don't set bluez5.roles. Narrowing it to [ a2dp_sink hfp_hf
              # hsp_hs ] broke profile selection — devices bond, then drop with
              # "a2dp-sink profile connect failed: Protocol not available".
              # Default is wider, so nothing loses a capability. (2026-08-05)
            };
          };

          # Switch a headset to HFP when an app opens its mic, then back to
          # A2DP afterwards. The radio can't carry high-quality stereo and a
          # mic channel at once — that's Bluetooth, not a bug — so this trades
          # audio quality for the duration of a call. mSBC above makes that
          # fallback 16 kHz wideband rather than 8 kHz telephone.
          #
          # Both of these are already wireplumber's defaults; they're written
          # out so the behaviour is visible here rather than implied, since
          # this is exactly the pair that gets blamed when a headset mic goes
          # missing.
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
