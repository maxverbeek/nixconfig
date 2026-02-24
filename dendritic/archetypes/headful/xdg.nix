{ ... }:
{
  flake.modules.nixos.xdg =
    { pkgs, ... }:
    {
      programs.dconf.enable = true;

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
}
