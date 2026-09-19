{
  nixos.system.cache =
    { lib, ... }:
    {
      # Leaves write `my.cachePackages.<name>` next to where they use the package;
      # packages.nix unions them across hosts into `nix build .#cache`.
      options.my.cachePackages = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "Extra packages to pre-build into the binary cache.";
      };
    };
}
