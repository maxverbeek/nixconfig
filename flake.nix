{
  description = "Flakey flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    olis-stuff.url = "github:Kranex/nixos-config";
    olis-stuff.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, unstable, home-manager, flake-utils, olis-stuff, ... }:

  let

    # config to extend nixpkgs. this needs to be applied as a module
    nixpkgsConfig = rec {
      config = {
        allowUnfree = true;
      };

      overlays = [
        # adding custom packages/flakes to nixpkgs
        (final: prev: {
          custom   = builtins.mapAttrs (n: d: final.callPackage d {}) (import ./packages);
          unstable = import unstable { inherit (prev) system; inherit config; };
          oli      = import nixpkgs { inherit (prev) system; inherit config; overlays = olis-stuff.overlays; };
        })

        # for any package version overrides
        (import ./overlays)
      ];
    };

    # modules to configure nixos
    hmsettings = { withModules ? [] }: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      # set up everything in home-manager
      home-manager.users.max.imports = [
        ./home/max.nix
        ./hosts/options.nix
      ] ++ withModules;
    };

    pin-flake-reg = {
      nix.registry.nixpkgs.flake = nixpkgs;
      nix.registry.unstable.flake = unstable;
      nix.registry.self.flake = self;
    };

    # modules defined above
    commonModules = [
      ({ nixpkgs = nixpkgsConfig; })
      pin-flake-reg

      # add home-manager as a module
      home-manager.nixosModules.home-manager
    ];

    eachSystemExport = flake-utils.lib.eachDefaultSystem (system: {
      packages = (import nixpkgs { inherit system; inherit (nixpkgsConfig) config overlays; }).custom;
    });

  in
  {
    templates = import ./templates;

    nixosConfigurations = {

      # PC at home
      desknix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./hosts/desknix/configuration.nix
          (hmsettings { withModules = [ ./hosts/desknix/device.nix ]; })
        ];
      };

      # Laptop for work
      lenovo-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./hosts/lenovo-laptop/configuration.nix
          (hmsettings { withModules = [ ./hosts/lenovo-laptop/device.nix ]; })
        ];
      };
    };
  } // eachSystemExport;
}
