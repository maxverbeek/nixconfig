# Wires lib/ (docs/wiring.md §2). Imports the nixpkgs lib *directory* rather
# than `sources.nixpkgs.lib`, so a plain npins source works identically.
{ my }:
let
  lib = import "${my.sources.nixpkgs}/lib";
in
{
  modules = import ./lib/modules.nix { inherit lib; };
}
