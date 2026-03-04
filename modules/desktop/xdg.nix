{ ... }:
{
  flake.modules.nixos.headful =
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
      };
    };
}
