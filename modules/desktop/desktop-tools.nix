{ ... }:
{
  # Desktop CLI tools that predate the retired ags bar and outlive it.
  # (The bar itself is barbell.nix; nmcli comes with
  # networking.networkmanager.enable, upower moved to barbell.nix.)
  flake.modules.nixos.headful =
    { pkgs, ... }:
    {
      services.gvfs.enable = true;

      environment.systemPackages = with pkgs; [
        fd
        brightnessctl
        swappy
        wayshot
        wl-clipboard
      ];
    };
}
