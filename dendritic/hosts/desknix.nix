{ inputs, config, ... }:
{
  flake.nixosConfigurations.desknix = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      config.flake.modules.nixos.max
    ];
  };
}
