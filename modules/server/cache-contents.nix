{ lib, ... }:
{
  # Extra derivations the VPS pre-builds for the binary cache, beyond the host
  # closures (which already cover everything installed on a host). Modules add
  # to `perSystem.cachePackages` next to where they use the package;
  # `nix build .#cache` realises the whole list.
  perSystem =
    { pkgs, config, ... }:
    {
      options.cachePackages = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "Extra packages to pre-build into the binary cache.";
      };

      config.packages.cache = pkgs.linkFarm "binary-cache-contents" (
        lib.mapAttrsToList (name: path: { inherit name path; }) config.cachePackages
      );
    };
}
