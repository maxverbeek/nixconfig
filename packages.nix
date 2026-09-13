# Wires packages/ (docs/wiring.md §2, §6). The only file permitted to turn
# modules into derivations.
#
# Implemented here: ROUTE 1, `wrappers.config.*` -> `my.pkgs.wrapped.*`.
# ROUTE 2 (the nvim builder), ROUTE 3 (packages/definitions/* via callPackage)
# and ROUTE 4 (the binary cache) arrive later.
{ my }:
let
  # This is a wiring file, so it owns its nixpkgs import rather than borrowing
  # flake-parts'. `system` must be explicit: `builtins.currentSystem` is
  # unavailable under pure flake evaluation, and this repo is x86_64-linux only.
  pkgs = import my.sources.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  wlib = (import my.sources.wrappers { inherit pkgs; }).lib;

  # ROUTE 1: wrappers.config.* -> my.pkgs.wrapped.*
  wrapped = builtins.mapAttrs (
    _: module:
    (wlib.evalModules {
      specialArgs = { inherit my; };
      modules = [
        { inherit pkgs; }
        module
      ];
    }).config.wrapper
  ) my.modules.wrappers.config;
in
{
  inherit wrapped;
}
