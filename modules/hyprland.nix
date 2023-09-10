{ config, lib, pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
  };

  # if nvidia patches for hyprland are required, then so is this modesetting thing
  hardware.nvidia.modesetting.enable =
    config.programs.hyprland.enableNvidiaPatches;

  services.xserver = {
    # enable = lib.mkForce false;
    desktopManager.xterm.enable = false;
    displayManager.lightdm.greeter.enable = true;

    desktopManager.session = [{
      manage = "desktop";
      name = "default"; # was previously "home-manager"
      start = ''
        exec $HOME/.xsession &
      '';
    }];
  };

  services.greetd.enable = false;
  programs.regreet.enable = false;

  services.pipewire.enable = true;
  services.pipewire.wireplumber.enable = true;
}
