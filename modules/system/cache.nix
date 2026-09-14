{
  nixos.system.cache =
    { lib, ... }:
    {
      # Contributions from shards land here: a leaf writes
      # `cachePackages.<name> = my.pkgs.<name>` next to where it uses the
      # package. ROUTE 4 in packages.nix collects them across all hosts into
      # `my.pkgs.cache`, which the VPS realises as `nix build .#cache`.
      options.cachePackages = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "Extra packages to pre-build into the binary cache.";
      };
    };
}
