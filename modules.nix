{ my }:
my.lib.modules.importSharded 3 ./modules
// {
  # Third-party NixOS modules; a leaf imports my.modules.external.<name>.
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
