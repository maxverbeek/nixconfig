# Wires hosts (docs/wiring.md §2): modules + meta become NixOS systems. `hosts`
# is a product, not a truth; it sits in the knot because it is consumed from
# outside. `my.hosts.<name>` is named by string from system.autoUpgrade on the
# running machines and from flake.nix, so renaming a host is a deploy change.
{ my }:
let
  # The nixpkgs *flake*, not the source tree: nixosSystem stamps
  # system.nixos.versionSuffix/revision from the flake's own metadata, and that
  # string is baked into the toplevel name. Plain eval-config would change every
  # closure, so hosts are the one product the lock fallback cannot build.
  lib =
    my.sources.nixpkgs.lib
      or (throw "my.hosts needs the nixpkgs flake, which only flake.nix supplies; a bare `import ./. { }` resolves sources from flake.lock and reaches the package side only");
in
builtins.mapAttrs (
  name: hostModule:
  lib.nixosSystem {
    specialArgs = { inherit my; };
    modules = [
      hostModule
      {
        networking.hostName = lib.mkDefault name;
        # Was modules/nixpkgs.nix. No overlays any more (docs/structure.md rule 7):
        # repo packages are my.pkgs.*, the second nixpkgs is my.pkgs.unstable.*.
        nixpkgs.config.allowUnfree = true;
        # Was modules/system/registry.nix. Flake refs exist only at the root.
        nix.registry = {
          nixpkgs.flake = my.sources.nixpkgs;
          unstable.flake = my.sources.unstable;
          self.flake = my.sources.self;
        };
      }
    ];
  }
) my.modules.nixos.hosts
