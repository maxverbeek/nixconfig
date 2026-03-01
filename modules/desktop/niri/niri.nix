{ ... }:
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      # Niri
      environment.systemPackages = [
        pkgs.niri
        pkgs.xwayland-satellite
      ];

      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-gtk
        ];
        configPackages = [ pkgs.niri ];
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      services.displayManager.sessionPackages = [ pkgs.niri ];
    };

  # Home-manager: niri config symlink — contributes to headful
  flake.modules.homeManager.niri =
    { config, ... }:
    {
      # Symlink niri config from the repo (mutable)
      home.file.".config/niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink "/home/max/nixconfig/modules/desktop/niri/niri-config.kdl";
    };
}
