{
  nixos.programs.niri =
    { my, pkgs, ... }:
    {
      # The mutable variant is the installed compositor: its NIRI_CONFIG points
      # at the working-tree kdl, so editing it hot-reloads without a rebuild.
      # The pure `niri` wrapper exists to stay buildable and validated
      # (`nix build .#wrapped.niri`); only one of the two can own niri.desktop.
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

      # was roles/headful.nix: the compositor needs max in `video` for
      # brightness/backlight control.
      users.users.max.extraGroups = [ "video" ];
    };
}
