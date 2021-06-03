{
  description = "Flakey flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, unstable, home-manager, ... }:

  let
    overlayUnstable = final: prev: {
      unstable = import unstable {
        system = final.system;
        config.allowUnfree = true;
      };
    };

    overlayCustom = import ./overlays;
 
    overlays.nixpkgs = {
      config.allowUnfree = true;
      overlays = [ overlayUnstable overlayCustom ];
    };

    hmsettings = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };

    pin-flake-reg = {
      nix.registry.nixpkgs.flake = nixpkgs;
      nix.registry.unstable.flake = unstable;
      nix.registry.self.flake = self;
    };

  in
  {
    nixosConfigurations.desknix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        overlays
        hmsettings
        home-manager.nixosModules.home-manager
        pin-flake-reg
        ./configuration.nix
      ];
    };

    legacyPackages.x86_64-linux = self.nixosConfigurations.desknix.pkgs;
  };
}
