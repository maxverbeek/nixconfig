# Wires modules/ (docs/wiring.md §2, §4). Every file below modules/ is a shard:
# an attrset keyed by module class, three levels deep
# (`nixos.<namespace>.<name>`), aggregated per leaf into one virtual module.
{ my }:
my.lib.modules.importSharded 3 ./modules
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
