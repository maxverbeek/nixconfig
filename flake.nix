{
  description = "Flakey flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    oldpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    # hyprland.url = "github:hyprwm/Hyprland?ref=refs/tags/v0.40.0";

    # text2url.url = "github:maxverbeek/text2url";
  };

  outputs =
    { self, nixpkgs, oldpkgs, unstable, home-manager, flake-utils, ... }:

    let

      # config to extend nixpkgs. this needs to be applied as a module
      nixpkgsConfig = rec {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "teams-1.5.00.23861" ];
        };

        overlays = [
          # adding custom packages/flakes to nixpkgs
          (final: prev: {
            custom = builtins.mapAttrs (n: d: final.callPackage d { })
              (import ./packages);
            unstable = import unstable {
              inherit (prev) system;
              inherit config;
            };
            oldpkgs = import oldpkgs {
              inherit (prev) system;
              inherit config;
            };

          })

          # packages from flakes
          (final: prev:
            {
              # text2url = text2url.packages.${final.system}.default;
            })

          # for any package version overrides
          (import ./overlays)
        ];
      };

      # modules to configure nixos
      hmsettings = { withModules ? [ ] }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        # set up everything in home-manager
        home-manager.users.max.imports = [ ./home/max.nix ./hosts/options.nix ]
          ++ withModules;
      };

      pin-flake-reg = {
        nix.registry.nixpkgs.flake = nixpkgs;
        nix.registry.unstable.flake = unstable;
        nix.registry.self.flake = self;
      };

      cachix = {
        nix.settings = {
          substituters = [ "https://hyprland.cachix.org" ];
          trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          ];
        };
      };

      # modules defined above
      commonModules = [
        ({ nixpkgs = nixpkgsConfig; })
        pin-flake-reg

        cachix

        # add home-manager as a module
        home-manager.nixosModules.home-manager

        # use hyperland's modules
        # hyprland.nixosModules.default
        # hyprland.homeManagerModules.default
      ];

      eachSystemExport = flake-utils.lib.eachDefaultSystem (system: {
        packages = (import nixpkgs {
          inherit system;
          inherit (nixpkgsConfig) config overlays;
        }).custom;
      });

    in {
      templates = import ./templates;

      nixosConfigurations = {

        # PC at home
        desknix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { nvidia = true; };
          modules = commonModules ++ [
            ./hosts/desknix/configuration.nix
            (hmsettings { withModules = [ ./hosts/desknix/device.nix ]; })
          ];
        };

        # Laptop for work
        lenovo-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { nvidia = false; };
          modules = commonModules ++ [
            ./hosts/lenovo-laptop/configuration.nix
            (hmsettings { withModules = [ ./hosts/lenovo-laptop/device.nix ]; })
          ];
        };
      };
    } // eachSystemExport;
}
