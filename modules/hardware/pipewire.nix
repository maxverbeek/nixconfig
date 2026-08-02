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
              # Only the roles where this laptop drives a headset or speaker.
              # The *_ag / a2dp_source roles are the other direction — laptop
              # acting as the phone-side gateway, so a handset routes its call
              # audio through here. Never used, and dropping them narrows what
              # can be negotiated on connect.
              #
              # hfp_hf and hsp_hs are what give you the headset microphone;
              # removing those would cost the mic entirely.
              "bluez5.roles" = [
                "a2dp_sink"
                "hfp_hf"
                "hsp_hs"
              ];
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
