# Wires modules/ (docs/wiring.md §2, §4).
#
# During the migration the two loaders share `modules/` and split it by file
# shape: this one takes the shards, import-tree (from flake.nix) takes the
# flake-parts files. That lets a directory be converted one stage at a time.
# When flake-parts goes, the filter is removed and this walks all of `modules/`.
{ my }:
my.lib.modules.importSharded 3 (
  builtins.filter my.lib.modules.isShard (my.lib.modules.listFiles ./modules)
)
// {
  # Third-party NixOS modules are wired once, here (docs/structure.md rule 6).
  # A leaf writes `imports = [ my.modules.external.walker ]` and never reads
  # my.sources itself.
  external = {
    walker = my.sources.walker.nixosModules.default;
    stalker = my.sources.stalker.nixosModules.default;
    disko = my.sources.disko.nixosModules.disko;
    agenix = my.sources.agenix.nixosModules.default;
    breadhero = my.sources.breadhero.nixosModules.default;
    copd = my.sources.copd.nixosModules.default;
    feedbackers = my.sources.feedbackers.nixosModules.default;
    huurhunter-web = my.sources.huurhunter.nixosModules.web;
    huurhunter-monitor = my.sources.huurhunter.nixosModules.monitor;
  };
}
