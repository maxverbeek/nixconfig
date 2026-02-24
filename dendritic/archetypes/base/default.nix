{ config, ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        _1password
        bluetooth
        cachix
        docker
        fonts
        nix-config
        pipewire
        printer
        registry
        shell
      ];

      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "Europe/Amsterdam";

      console = {
        font = "Lat2-Terminus16";
        useXkbConfig = true;
      };
    };

  flake.modules.homeManager.base =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        gtk
        shell
        ssh
        terminal
      ];

      programs.man.enable = true;
    };
}
