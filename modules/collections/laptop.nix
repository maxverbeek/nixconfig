{
  nixos.collections.laptop =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        hardware.tlp
        hardware.laptop
      ];
    };
}
