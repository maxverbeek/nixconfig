{ lib, pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./niri
    ./nvidia.nix
    ./greeter.nix
  ];

  services.xserver.enable = lib.mkForce false;

  programs.dconf.enable = true;

  services.dbus.packages = [ pkgs.gcr ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  home-manager.users.max.xsession.enable = lib.mkForce false;

  # testing!
  modules.niri.enable = true;
  modules.niri.package = pkgs.unstable.niri.override { mesa = pkgs.mesa; };
}
