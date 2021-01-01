{
  description = "Flakey flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, unstable, home-manager, ... }:
  let
    overlayUnstable = final: prev: {
      unstable = import unstable {
        system = final.system;
        config.allowUnfree = true;
      };
    };
 
    overlays.nixpkgs = {
      config.allowUnfree = true;
      overlays = [ overlayUnstable ];
    };

    hmsettings = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };

  in
  {
    nixosConfigurations.desknix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        overlays
        hmsettings
        home-manager.nixosModules.home-manager
        ./configuration.nix
      ];
    };
  };
}
