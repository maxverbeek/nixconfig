{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkPackageOption mkEnableOption mkIf;

  cfg = config.modules.niri;
in
{
  options.modules.niri = {
    enable = mkEnableOption "Enable Niri tiling window manager";

    package = mkPackageOption pkgs "niri" { extraDescription = "Which package to use for Niri"; };
  };

  config = mkIf config.modules.niri.enable {
    environment.systemPackages = [ cfg.package ];
    services.displayManager.sessionPackages = [ cfg.package ];

    xdg = {
      autostart.enable = true;
      menus.enable = true;
      mime = {
        enable = true;
        # todo: migrate away from home manager
        defaultApplications = {
          "inode/directory" = [ "neovim-opener.desktop" ];
          "text/plain" = [ "neovim-opener.desktop" ];
        };
      };
      icons.enable = true;
      portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };
  };
}
