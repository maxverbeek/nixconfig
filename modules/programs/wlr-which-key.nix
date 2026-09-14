{
  nixos.programs.wlr-which-key =
    { my, ... }:
    {
      environment.systemPackages = [ my.pkgs.wrapped.wlr-which-key ];
    };
}
