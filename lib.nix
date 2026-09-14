{ my }:
let
  lib = import "${my.sources.nixpkgs}/lib";
in
{
  modules = import ./lib/modules.nix { inherit lib; };
  colors = import ./lib/colors.nix { inherit lib; };
}
