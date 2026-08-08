{ ... }:
{
  flake.modules.nixos.headful =
    { ... }:
    {
      services.gvfs.enable = true;
    };

  # Desktop CLI tools that predate the retired ags bar and outlive it.
  # (The bar itself is barbell.nix; nmcli comes with
  # networking.networkmanager.enable, upower moved to barbell.nix.)
  flake.modules.homeManager.headful =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        fd
        brightnessctl
        swappy
        wayshot
        wl-clipboard
      ];
    };
}
