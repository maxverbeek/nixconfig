{
  nixos.system.cache =
    { lib, ... }:
    {
      # Contributions from shards land here: a leaf writes
      # `cachePackages.<name> = my.pkgs.<name>` next to where it uses the
      # package. ROUTE 4 in packages.nix collects them when flake-parts goes;
      # until then `nix build .#cache` only sees the perSystem contributions
      # from the still-unconverted files (modules/server/cache-contents.nix).
      options.cachePackages = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "Extra packages to pre-build into the binary cache.";
      };
    };
}
