{ pkgs, ... }:
pkgs.vimPlugins.NotebookNavigator-nvim.overrideAttrs (oldAttrs: {
  version = "2025-12-24";
  src = pkgs.fetchFromGitHub {
    owner = "vandalt";
    repo = "NotebookNavigator.nvim";
    rev = "3bcffd2d57dffe76a2745da993176e23f497005f";
    sha256 = "sha256-agpTshwZhFHEMuANUKkqHIO1h5x8XFQHa5vWGo8ylrw=";
  };
})
