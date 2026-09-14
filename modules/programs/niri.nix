{
  nixos.programs.niri =
    { my, pkgs, ... }:
    {
      # The mutable variant is installed: its NIRI_CONFIG points at the
      # working-tree kdl, so editing it hot-reloads without a rebuild. The pure
      # `niri` wrapper stays buildable for validation; only one can own
      # niri.desktop.
      environment.systemPackages = [
        my.pkgs.wrapped.niri-mutable
        pkgs.xwayland-satellite
      ];

      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-gtk
        ];
        configPackages = [ my.pkgs.wrapped.niri-mutable ];
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      services.displayManager.sessionPackages = [ my.pkgs.wrapped.niri-mutable ];

      # The compositor needs max in `video` for brightness/backlight control.
      users.users.max.extraGroups = [ "video" ];
    };
}
