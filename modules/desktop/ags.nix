{ ... }:
{
  flake.modules.nixos.headful =
    { ... }:
    {
      services.upower.enable = true;
      services.gvfs.enable = true;
    };

  # The ags bar itself is retired — barbarella.nix runs the quickshell bar now.
  # The tools below predate ags and outlive it.
  flake.modules.homeManager.headful =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        fd
        brightnessctl
        networkmanager
        swappy
        wayshot
      ];
    };
}
