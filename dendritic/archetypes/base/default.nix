{ ... }:
{
  # The base archetype is composed entirely from the individual modules in this directory.
  # import-tree automatically discovers all .nix files here.
  #
  # Hosts that use the base archetype should include:
  #   config.flake.modules.nixos.base
  #   config.flake.modules.homeManager.base
  #
  # This file defines the composite modules that aggregate the individual features.

  flake.modules.nixos.base =
    { pkgs, lib, ... }:
    {
      # Common system settings shared by all hosts
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "Europe/Amsterdam";

      console = {
        font = "Lat2-Terminus16";
        useXkbConfig = true;
      };
    };

  flake.modules.homeManager.base = {
    # Base home-manager settings shared by all hosts
    programs.man.enable = true;
  };
}
