{ lib, ... }:
{
  # flake-parts has no built-in `flake.lib` output, so without a declaration
  # here two modules both setting `flake.lib.<something>` collide with
  # "defined multiple times ... can't be merged automatically".
  # Declaring it as an attrsOf makes the usual per-file split work.
  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Repo-wide helpers, shared across modules.";
  };
}
