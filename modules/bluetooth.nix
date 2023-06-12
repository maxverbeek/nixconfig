{ ... }: {
  users.users.max.extraGroups = [ "bluetooth" ];

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = { Enable = "Source,Sink,Media,Socket"; };

    };
  };

  services.blueman.enable = true;

  services.pipewire.wireplumber.enable = true;

  # Configure bluetooth options for pipewire
  # DEPRECATED in 23.05 maybe
#   services.pipewire.media-session.config.bluez-monitor.rules = [
#     {
#       # Matches all cards
#       matches = [{ "device.name" = "~bluez_card.*"; }];
#       actions = {
#         "update-props" = {
#           "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
#           # mSBC is not expected to work on all headset + adapter combinations.
#           "bluez5.msbc-support" = true;
#           # SBC-XQ is not expected to work on all headset + adapter combinations.
#           "bluez5.sbc-xq-support" = true;
#
#           # try autoswitching profiles to something that supports mic whenever mic input is required
#           "bluez5.autoswitch-profile" = true;
#         };
#       };
#     }
#     {
#       matches = [
#         # Matches all sources
#         {
#           "node.name" = "~bluez_input.*";
#         }
#         # Matches all outputs
#         { "node.name" = "~bluez_output.*"; }
#       ];
#     }
#   ];
}
