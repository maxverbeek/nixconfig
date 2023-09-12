{ config, lib, pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    # enableNvidiaPatches = true;
    # portalPackage = pkgs.xdg-desktop-portal-wlr;
  };

  # if nvidia patches for hyprland are required, then so is this modesetting thing
  hardware.nvidia = lib.optionalAttrs true {
    # open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = lib.optionals true [ pkgs.nvidia-vaapi-driver ];
  };

  # required for pipewire?
  boot.kernelModules = [ "v4l2loopback" ];

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    # displayManager.lightdm.greeter.enable = true;

    desktopManager.session = [{
      manage = "desktop";
      name = "default"; # was previously "home-manager"
      start = ''
        exec $HOME/.xsession &
      '';
    }];
  };

  # services.greetd.enable = true;
  # programs.regreet.enable = true;

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  hardware.pulseaudio.enable = lib.mkForce false;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  home-manager.users.max.xsession.enable = lib.mkForce false;
}
