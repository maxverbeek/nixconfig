{ inputs, ... }:
{
  flake.modules.nixos.registry = {
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    nix.registry.unstable.flake = inputs.unstable;
    nix.registry.self.flake = inputs.self;
  };
}
