{ my }:
let
  # The nixpkgs flake's lib, not the source tree's: nixosSystem stamps the
  # flake's version metadata into every closure name, so hosts cannot be built
  # from the flake.lock fallback.
  lib =
    my.sources.nixpkgs.lib
      or (throw "my.hosts needs the nixpkgs flake, which only flake.nix supplies; a bare `import ./. { }` reaches the package side only");
in
builtins.mapAttrs (
  name: hostModule:
  lib.nixosSystem {
    specialArgs = { inherit my; };
    modules = [
      hostModule
      {
        networking.hostName = lib.mkDefault name;
        nixpkgs.config.allowUnfree = true;
        nix.registry = {
          nixpkgs.flake = my.sources.nixpkgs;
          unstable.flake = my.sources.unstable;
          self.flake = my.sources.self;
        };
      }
    ];
  }
) my.modules.nixos.hosts
