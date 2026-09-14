{
  nixos.hardware.bluetooth =
    { pkgs, ... }:
    let
      # vendored: github .patch URLs are not byte-stable, fetchpatch broke once
      bluezPatched = pkgs.bluez.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./bluez-066a164-sink-after-source.patch
        ];
      });
    in
    {
      # Pre-build it: a bluez rebuild is expensive and every headful host needs it.
      cachePackages.bluez = bluezPatched;

      users.users.max.extraGroups = [ "bluetooth" ];

      hardware.bluetooth = {
        enable = true;

        # bluez 5.86 races a2dp-source ahead of a2dp-sink, so dual-role audio
        # devices never register as a sink ("connect failed: Device or resource
        # busy"). Fixed upstream in 066a164, unreleased; drop once nixpkgs ships
        # bluez >= 5.87. Scoped to the package here, not an overlay, so pipewire
        # & friends don't rebuild. https://github.com/bluez/bluez/issues/1898
        package = bluezPatched;
        # No `Enable = "Source,Sink,..."` here: that is a BlueZ *4* audio.conf
        # key, ignored (and logged as unknown) since BlueZ 5.
      };

      services.blueman.enable = true;
      services.pipewire.wireplumber.enable = true;
    };
}
