{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      callPackage = pkgs.callPackage;

      packages = builtins.mapAttrs (_: path: callPackage path { }) {
        pngcrop = ./_definitions/pngcrop;
        fa-custom = ./_definitions/fontawesome-custom;
        teg-font = ./_definitions/teg-font;
        volantes-cursors = ./_definitions/volantes-cursors;
        mcmojave-cursors = ./_definitions/mcmojave-cursors;
        responsively-app = ./_definitions/responsively-app;
        neovim-ayu = ./_definitions/neovim-ayu;
        neovim-opener-desktop = ./_definitions/neovim-opener-desktop;
        vim-pandoc-markdown-preview = ./_definitions/vim-pandoc-markdown-preview;
        kiro = ./_definitions/kiro;
        rubocop = ./_definitions/rubocop;
        samdump2 = ./_definitions/samdump2;
      };

      vimPlugins = builtins.mapAttrs (_: fn: callPackage fn { }) (import ./_definitions/vimPlugins);

      # Full custom package set
      custom = packages // vimPlugins;
    in
    {
      # legacyPackages allows nested attrsets; used by the pkgs.custom overlay
      legacyPackages.custom = custom;

      # Flat derivations only, for `nix build .#<name>`
      packages = packages // vimPlugins;
    };
}
