{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    # nvidiaPatches = useNvidia;
  };
}
