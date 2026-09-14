{ my }:
let
  # builtins.currentSystem is unavailable in pure evaluation; x86_64-linux only.
  system = "x86_64-linux";

  unstable = import my.sources.unstable {
    inherit system;
    config.allowUnfree = true;
  };

  pkgs = import my.sources.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    # so package definitions and wrapper shards can write pkgs.unstable.<x>
    overlays = [ (_: _: { inherit unstable; }) ];
  };

  inherit (pkgs) lib;

  wlib = (import my.sources.wrappers { inherit pkgs; }).lib;

  # wrappers.configured.* -> my.pkgs.wrapped.*
  wrapped = builtins.mapAttrs (
    _: module:
    (wlib.evalModules {
      specialArgs = { inherit my; };
      modules = [
        { inherit pkgs; }
        module
      ];
    }).config.wrapper
  ) my.modules.wrappers.configured;

  # packages/definitions/* -> callPackage
  definitions = builtins.mapAttrs (_: p: pkgs.callPackage p { }) (
    my.lib.modules.importDir ./packages/definitions
  );

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

    # The input's overlay builds against our nixpkgs. Its own `packages` output
    # is what its cachix cache serves, but that is a different derivation.
    claude-code = (my.sources.claude-code.overlays.default pkgs pkgs).claude-code;

    # a source tree, not a package: gtk.nix reads css files out of it
    adw-catppuccin = my.sources.adw-catppuccin;
  };

  nvim = import ./packages/neovim {
    inherit pkgs unstable;
    repoRoot = my.meta.repoRoot;
    inherit (fromInputs) gitlab-reviewer;
    inherit (definitions) NotebookNavigator-nvim;
  };

  # Every host's cachePackages in one linkFarm. harmonia's prebuild unit names
  # `cache` by string, so renaming it breaks the nightly silently.
  cache = pkgs.linkFarm "binary-cache-contents" (
    lib.foldl' (acc: host: acc // host.config.cachePackages) { } (builtins.attrValues my.hosts)
  );

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
  inherit unstable cache devShells;
  wrapped = wrapped // nvim;
}
