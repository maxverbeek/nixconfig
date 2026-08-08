{ ... }:
let
  # vendored: github .patch URLs are not byte-stable, fetchpatch broke once
  bluezPatched =
    pkgs:
    pkgs.bluez.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./bluez-066a164-sink-after-source.patch
      ];
    });
in
{
  # Pre-build it: a bluez rebuild is expensive and every headful host needs it.
  perSystem =
    { pkgs, ... }:
    {
      cachePackages.bluez = bluezPatched pkgs;
    };

  flake.modules.nixos.multimedia =
    { pkgs, ... }:
    {
      users.users.max.extraGroups = [ "bluetooth" ];

      hardware.bluetooth = {
        enable = true;

        # Dual-role bluetooth audio devices (ones advertising both A2DP Source
        # and Sink — the Philips S7505, most soundbars, plenty of earbuds) fail
        # to register as an audio sink on bluez 5.86: bluetoothd logs
        #
        #   a2dp-sink profile connect failed for <addr>: Device or resource busy
        #
        # bluez cdcd845f87ee inverted the order same-priority profiles connect
        # in, so a2dp-source now races ahead of a2dp-sink, and "connecting both
        # at the same time does not work currently" (upstream's words). The
        # EBUSY is bluez's own in-flight connect state in profiles/audio/sink.c,
        # not the remote refusing us — which is why having another device already
        # connected to the speaker makes it far more likely: it widens the race.
        #
        # Fixed upstream in 066a164 (three lines, adds .after_services), merged
        # but not in any release — 5.87 doesn't exist yet. Arch carries the same
        # patch in 5.86-5. Drop this override once nixpkgs ships bluez >= 5.87.
        #
        # Scoped to hardware.bluetooth.package (only bluetoothd needs the fix)
        # instead of an overlay, so pipewire & friends don't rebuild.
        #
        # https://github.com/bluez/bluez/issues/1898
        package = bluezPatched pkgs;
        # `Enable = "Source,Sink,Media,Socket"` used to live here. That's a
        # BlueZ *4* audio.conf key — BlueZ 5 dropped the socket audio interface
        # in 2013 and logs `Unknown key Enable for group General` on every boot.
        # It has never done anything on this machine.
      };

      services.blueman.enable = true;
      services.pipewire.wireplumber.enable = true;
    };
}
