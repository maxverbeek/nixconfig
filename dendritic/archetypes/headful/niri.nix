{ ... }:
{
  # NixOS module for niri tiling window manager
  flake.modules.nixos.niri =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.niri;
    in
    {
      options.modules.niri = {
        enable = lib.mkEnableOption "Enable Niri tiling window manager";
        package = lib.mkPackageOption pkgs "niri" { extraDescription = "Which package to use for Niri"; };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];
        services.displayManager.sessionPackages = [ cfg.package ];

        xdg = {
          autostart.enable = true;
          menus.enable = true;
          mime = {
            enable = true;
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
    };

  # Home-manager: niri config symlink
  flake.modules.homeManager.niri =
    { config, ... }:
    {
      # Symlink niri config from the repo (mutable)
      home.file.".config/niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink "/home/max/dendritic/dendritic/archetypes/headful/niri-config.kdl";
    };
}
