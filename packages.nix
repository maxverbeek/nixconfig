# Wires packages/ (docs/wiring.md §2, §6). The only file permitted to turn
# modules into derivations.
#
# Implemented here: ROUTE 1 (`wrappers.config.*` -> `my.pkgs.wrapped.*`),
# ROUTE 2 (the nvim builder) and ROUTE 3 (`packages/definitions/*` via
# callPackage). ROUTE 4 (the binary cache) arrives later.
{ my }:
let
  # This is a wiring file, so it owns its nixpkgs imports rather than borrowing
  # flake-parts'. `system` must be explicit: `builtins.currentSystem` is
  # unavailable under pure flake evaluation, and this repo is x86_64-linux only.
  system = "x86_64-linux";

  unstable = import my.sources.unstable {
    inherit system;
    config.allowUnfree = true;
  };

  pkgs = import my.sources.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    # Package definitions and wrapper shards write `pkgs.unstable.<x>` the same
    # way the rest of the repo does; keep that spelling working here.
    overlays = [ (_: _: { inherit unstable; }) ];
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

  # ROUTE 3: packages/definitions/* -> callPackage. No module system involved.
  definitions = builtins.mapAttrs (_: p: pkgs.callPackage p { }) (
    my.lib.modules.importDir ./packages/definitions
  );

  # Packages that come from flake inputs rather than nixpkgs or packages/.
  # Only the root may read my.sources (docs/wiring.md §1); shards take these
  # from my.pkgs instead.
  fromInputs = {
    stalker = my.sources.stalker.packages.${system}.default;
    gitlab-reviewer = my.sources.gitlab-reviewer.packages.${system}.default;
  };

  # ROUTE 2: the nvim special case (docs/wiring.md §8).
  nvim = import ./packages/neovim {
    inherit pkgs unstable;
    repoRoot = my.meta.repoRoot;
    inherit (fromInputs) gitlab-reviewer;
    inherit (definitions) NotebookNavigator-nvim;
  };
in
definitions // fromInputs // { wrapped = wrapped // nvim; }
