{ pkgs, ... }:

let
  nvimDesktopItem = pkgs.makeDesktopItem {
    name = "neovim-opener";
    exec = "${pkgs.foot}/bin/foot -e nvim %F";
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
  };
in

pkgs.stdenv.mkDerivation {
  pname = "neovim-opener-desktop";
  version = "1.0";

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/applications
    cp ${nvimDesktopItem}/share/applications/* $out/share/applications/
  '';
}
