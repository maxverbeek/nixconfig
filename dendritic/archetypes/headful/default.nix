{ ... }:
{
  # The headful archetype represents a desktop environment with wayland, niri, ags, etc.
  # Individual components are in separate files in this directory.

  flake.modules.nixos.headful =
    { pkgs, lib, ... }:
    {
      # Wayland session environment
      services.xserver.enable = lib.mkForce false;
      programs.dconf.enable = true;
      services.dbus.packages = [ pkgs.gcr ];
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

      # Enable niri by default in headful
      modules.niri.enable = true;

      # Xwayland satellite (disabled by default, but package installed)
      modules.xwayland-satellite = {
        enable = false;
        package = pkgs.unstable.xwayland-satellite.override { xwayland = pkgs.xwayland; };
        address = ":0";
      };
      environment.systemPackages = [ pkgs.xwayland-satellite ];

      # Hyprland
      programs.hyprland = {
        enable = true;
        package = pkgs.unstable.hyprland;
      };

      # upower + gvfs for ags
      services.upower.enable = true;
      services.gvfs.enable = true;
    };

  flake.modules.homeManager.headful =
    { lib, ... }:
    {
      # Force-disable xsession in wayland mode
      xsession.enable = lib.mkForce false;
    };
}
