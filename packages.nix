# Wires packages/ (docs/wiring.md §2, §6). The only file permitted to turn
# modules into derivations.
#
# Implemented here: ROUTE 1 (`wrappers.config.*` -> `my.pkgs.wrapped.*`),
# ROUTE 2 (the nvim builder), ROUTE 3 (`packages/definitions/*` via
# callPackage) and ROUTE 4 (the binary cache).
{ my }:
let
  # This is a wiring file, so it owns its nixpkgs imports. `system` must be
  # explicit: `builtins.currentSystem` is unavailable under pure flake
  # evaluation, and this repo is x86_64-linux only.
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

  inherit (pkgs) lib;

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
    barbell = my.sources.barbell.packages.${system}.default;
    clankertyper = my.sources.clankertyper.packages.${system}.default;
    elephant = my.sources.elephant.packages.${system}.default;
    elephant-gitlab = my.sources.elephant-gitlab.packages.${system}.default;
    stalker = my.sources.stalker.packages.${system}.default;
    stalker-git-hooks = my.sources.stalker.packages.${system}.git-hooks;
    gitlab-reviewer = my.sources.gitlab-reviewer.packages.${system}.default;
    opencode = my.sources.opencode.packages.${system}.default;
    xtee = my.sources.xtee.packages.${system}.default;
    zen-browser = my.sources.zen-browser.packages.${system}.default;

    breadhero = my.sources.breadhero.packages.${system}.default;
    copd = my.sources.copd.packages.${system}.default;
    feedbackers = my.sources.feedbackers.packages.${system}.default;
    huurhunter = my.sources.huurhunter.packages.${system}.default;

    # claude-code comes from the input's *overlay*, not its `packages`, and the
    # difference is real: the overlay builds against our nixpkgs, `packages`
    # against the input's own (which is what its cachix cache serves). Taking
    # the overlay keeps the derivation we build today; see flake.nix's
    # now-stale comment on the claude-code input.
    claude-code = (my.sources.claude-code.overlays.default pkgs pkgs).claude-code;

    # A plain source tree, not a flake package: gtk.nix reads css files out of
    # it. `lib.isDerivation` in flake.nix keeps a path out of the `packages`
    # output.
    adw-catppuccin = my.sources.adw-catppuccin;
  };

  # ROUTE 2: the nvim special case (docs/wiring.md §8).
  nvim = import ./packages/neovim {
    inherit pkgs unstable;
    repoRoot = my.meta.repoRoot;
    inherit (fromInputs) gitlab-reviewer;
    inherit (definitions) NotebookNavigator-nvim;
  };

  # ROUTE 4: the hosts' cachePackages -> my.pkgs.cache (docs/wiring.md §6b).
  # Each leaf declares `cachePackages.<name>` next to where it uses the package
  # (option: modules/system/cache.nix); this is the one place that collects
  # them. `cache` is named by string from harmonia's prebuild unit and
  # re-exported by flake.nix as `packages.cache`: renaming it breaks the VPS
  # nightly silently.
  cache = pkgs.linkFarm "binary-cache-contents" (
    lib.foldl' (acc: host: acc // host.config.cachePackages) { } (builtins.attrValues my.hosts)
  );

  # Was modules/devshell.nix. The CLIs come straight from the inputs, so this
  # is a root file.
  devShells.default = pkgs.mkShell {
    packages = [
      my.sources.agenix.packages.${system}.default
      my.sources.disko.packages.${system}.default
      pkgs.nixos-anywhere
      pkgs.git
    ];
  };
in
definitions
// fromInputs
// {
  # The second nixpkgs, as `my.pkgs.unstable.<x>` (docs/structure.md rule 7).
  # Not a derivation, so flake.nix's isDerivation filter drops it from the
  # `packages` output, same as `wrapped` and `devShells`.
  inherit unstable cache devShells;
  wrapped = wrapped // nvim;
}
