{
  nixos.system.cache =
    { lib, ... }:
    {
      # Leaves write `cachePackages.<name>` next to where they use the package;
      # packages.nix unions them across hosts into `nix build .#cache`.
      options.cachePackages = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "Extra packages to pre-build into the binary cache.";
      };
    };
}
