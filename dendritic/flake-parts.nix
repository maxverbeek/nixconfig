{ inputs, ... }:
{
  # allows writing typed modules in the flake.modules.nixos namespace as opposed to flake.nixosModules (which is
  # unchecked).
  # general usage: flake.modules.<class>.<name> = nixosmodule
  # e.g. flake.modules.nixos.desktop = { pkgs, ... }: { networking.networkmanager.enable = true; }
  # e.g. flake.modules.homeManager.desktop = { pkgs, ... }: { home.packages = [ htop ]; }
  # e.g. flake.modules.nixvim.desktop = { pkgs, ... }: { ... some nixvim settings ... } except i don't use nixvim
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
