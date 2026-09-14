{
  nixos.programs.go =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.go ];
    };
}
