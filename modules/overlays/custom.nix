{ config, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      custom = config.flake.legacyPackages.${prev.stdenv.hostPlatform.system}.custom;
      self = config.flake.packages.${prev.stdenv.hostPlatform.system};
    })
  ];
}
