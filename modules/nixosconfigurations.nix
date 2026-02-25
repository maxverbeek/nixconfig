{
  inputs,
  lib,
  config,
  ...
}:
{
  options.configurations.hosts = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = lib.flip lib.mapAttrs config.configurations.hosts (
      name:
      { module }:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          module
          { nixpkgs = config.nixpkgs; }
        ];
        specialArgs = { inherit inputs; };
      }
    );

    checks = lib.mkMerge (
      lib.flip lib.mapAttrsToList config.flake.nixosConfigurations (
        name: nixos: {
          ${nixos.config.nixpkgs.hostPlatform.system} = {
            "configurations/hosts/${name}" = nixos.config.system.build.toplevel;
          };
        }
      )
    );
  };
}
