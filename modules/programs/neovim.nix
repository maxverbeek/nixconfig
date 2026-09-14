{
  nixos.programs.neovim =
    { my, pkgs, ... }:
    {
      environment.systemPackages = [
        my.pkgs.wrapped.nvim-mutable
        my.pkgs.wrapped.nvim
        (pkgs.makeDesktopItem {
          name = "neovim-opener";
          exec = "${my.pkgs.wrapped.foot}/bin/foot -e ${my.pkgs.wrapped.nvim-mutable}/bin/nv %F";
          icon = "nvim";
          desktopName = "Open in Neovim";
          comment = "Edit files and folders in Neovim inside a terminal";
          categories = [
            "Utility"
            "Development"
          ];
          mimeTypes = [
            "inode/directory"
            "text/plain"
            "application/x-shellscript"
            "application/json"
            "application/xml"
            "application/x-yaml"
          ];
        })
      ];
    };
}
