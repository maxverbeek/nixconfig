{ config, pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
  };

  # if nvidia patches for hyprland are required, then so is this modesetting thing
  hardware.nvidia.modesetting.enable =
    config.programs.hyprland.enableNvidiaPatches;

  services.xserver = {
    desktopManager.xterm.enable = true;
    displayManager.sddm.enable = true;

    desktopManager.session = [{
      manage = "desktop";
      name = "default"; # was previously "home-manager"
      start = ''
        exec $HOME/.xsession &
      '';
    }];
  };

  services.pipewire.enable = true;
  services.pipewire.wireplumber.enable = true;
}
