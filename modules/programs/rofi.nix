{
  nixos.programs.rofi =
    { my, ... }:
    {
      environment.systemPackages = [ my.pkgs.wrapped.rofi ];
    };
}
