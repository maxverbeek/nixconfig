{ inputs, ... }:
{
  # allows writing typed modules in the flake.modules.nixos namespace as opposed to flake.nixosModules (which is
  # unchecked).
  # general usage: flake.modules.<class>.<name> = nixosmodule
  # e.g. flake.modules.nixos.desktop = { pkgs, ... }: { networking.networkmanager.enable = true; }
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.disko.flakeModules.disko
    # flake.wrappers.<name> -> packages.<system>.<name> (and pkgs.self.<name> via the overlay)
    inputs.wrappers.flakeModules.wrappers
  ];

  systems = [ "x86_64-linux" ];
}
