{ ... }:
{
  # The development archetype aggregates dev tooling.
  # Individual tools are in separate files in this directory.
  # This file provides the composite module references.

  flake.modules.nixos.development = {
    # No NixOS-level development settings needed at composite level
  };

  flake.modules.homeManager.development = {
    # No HM-level development settings needed at composite level
  };
}
