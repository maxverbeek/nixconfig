{
  description = "Flakey flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    oldpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";

    # xtee try out thingy
    xtee.url = "github:maxverbeek/xtee";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    # hyprland.url = "github:hyprwm/Hyprland?ref=refs/tags/v0.40.0";
    # text2url.url = "github:maxverbeek/text2url";
    # ags.url = "github:Aylur/ags?ref=refs/tags/v2.3.0";
    ags.url = "github:maxverbeek/astalconfig";

    elephant.url = "github:abenz1267/elephant";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      oldpkgs,
      unstable,
      nixpkgs-ruby,
      xtee,
      home-manager,
      flake-utils,
      ags,
      walker,
      zen-browser,
      ...
    }:

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
            custom = builtins.mapAttrs (n: d: final.callPackage d { }) (import ./packages);
            unstable = import unstable {
              inherit (prev) system;
              inherit config;

              overlays = [
                # neovim from nvim-on-nix overlay
                (import ./neovim)
              ];
            };
            oldpkgs = import oldpkgs {
              inherit (prev) system;
              inherit config;
            };

            ruby-custom = import nixpkgs-ruby {
              inherit (prev) system;
              inherit config;
            };

            zen-browser = zen-browser.packages.${prev.system};

            agsmax = ags.packages.${prev.system}.default;
          })

          # packages from flakes
          (final: prev: {
            # text2url = text2url.packages.${final.system}.default;
            xtee = xtee.packages.${prev.system}.default;
          })

          # for any package version overrides
          (import ./overlays)

          # neovim from nvim-on-nix overlay
          (import ./neovim)
        ];
      };

      # modules to configure nixos
      hmsettings =
        {
          withModules ? [ ],
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          # set up everything in home-manager
          home-manager.users.max.imports = [
            ./home/max.nix
            ./hosts/options.nix
            walker.homeManagerModules.default
          ]
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
          trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
          extra-substituters = [
            "https://walker.cachix.org"
            "https://walker-git.cachix.org"
          ];
          extra-trusted-public-keys = [
            "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
            "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
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

      eachSystemExport = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            inherit (nixpkgsConfig) config overlays;
          };
        in
        {
          packages = pkgs.custom;

          devShells.default = import ./shell.nix { inherit pkgs; };
        }
      );
    in
    {
      templates = import ./templates;

      nixosConfigurations = {

        # PC at home
        desknix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            nvidia = true;
          };
          modules = commonModules ++ [
            ./hosts/desknix/configuration.nix
            (hmsettings { withModules = [ ./hosts/desknix/device.nix ]; })
          ];
        };

        # Laptop for work
        thinkpad = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            nvidia = false;
          };
          modules = commonModules ++ [
            ./hosts/thinkpad/configuration.nix
            (hmsettings { withModules = [ ./hosts/thinkpad/device.nix ]; })
          ];
        };

        # Laptop for work
        lenovo-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            nvidia = false;
          };
          modules = commonModules ++ [
            ./hosts/lenovo-laptop/configuration.nix
            (hmsettings { withModules = [ ./hosts/lenovo-laptop/device.nix ]; })
          ];
        };
      };
    }
    // eachSystemExport;
}
