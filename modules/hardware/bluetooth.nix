{
  nixos.hardware.bluetooth =
    { ... }:
    {
      users.users.max.extraGroups = [ "bluetooth" ];

      hardware.bluetooth = {
        enable = true;

        # No `Enable = "Source,Sink,..."` here: that is a BlueZ *4* audio.conf
        # key, ignored (and logged as unknown) since BlueZ 5.
      };

      services.blueman.enable = true;
      services.pipewire.wireplumber.enable = true;
    };
}
