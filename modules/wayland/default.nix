{ lib, pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./niri
    ./nvidia.nix
    ./greeter.nix
    ./xwayland-satellite.nix
  ];

  services.xserver.enable = lib.mkForce false;

  programs.dconf.enable = true;

  services.dbus.packages = [ pkgs.gcr ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  home-manager.users.max.xsession.enable = lib.mkForce false;

  modules.niri.enable = true;
  # modules.niri.package = pkgs.unstable.niri.overrideAttrs (old: {
  #   buildInputs = ((builtins.filter (p: p != pkgs.unstable.libgbm) old.buildInputs) ++ [ pkgs.mesa ]);
  # });

  modules.xwayland-satellite = {
    enable = false;
    package = pkgs.unstable.xwayland-satellite.override { xwayland = pkgs.xwayland; };
    address = ":0";
  };

  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
