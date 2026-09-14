{
  # A machine on a battery. Today's portable role.
  nixos.collections.laptop =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        hardware.tlp
        hardware.laptop
      ];
    };
}
