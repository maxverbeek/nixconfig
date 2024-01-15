{ config, lib, pkgs, ... }:
let useNvidia = false;
in {
  programs.hyprland = {
    enable = true;
    # nvidiaPatches = useNvidia;
  };

  # if nvidia patches for hyprland are required, then so is this modesetting thing
  services.xserver.videoDrivers = lib.optionals useNvidia [ "nvidia" ];

  hardware.nvidia = lib.optionalAttrs useNvidia {
    # open = true;
    modesetting.enable = true;
    powerManagement.enable = false;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = lib.optionals useNvidia [ pkgs.nvidia-vaapi-driver ];
  };

  # required for pipewire?
  boot.kernelModules = [ "v4l2loopback" ];

  services.xserver = {
    enable = lib.mkForce false;
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

  programs.dconf.enable = true;

  services.dbus.packages = [ pkgs.gcr ];

  programs.regreet = {
    enable = true;
    package =
      pkgs.unstable.greetd.regreet; # .overrideAttrs (old: { patches = [ ../patches/regreet-debug.patch ]; });
    settings = {
      background = {
        path = ../wallpapers/windows.png;
        fit = "Cover";
      };

      GTK = {
        application_prefer_dark_theme = true;
        cursor_theme_name = "McMojave-cursors";
        # font_name = "Jost * 12";
        icon_theme_name = "Papirus-Dark";
        theme_name = "Catppuccin-Mocha-Compact-Mauve-Dark";
      };

      commands = {
        reboot = [ "reboot" ];
        poweroff = [ "shutdown" "now" ];
      };
    };
  };

  # themes for regreet
  environment.systemPackages = with pkgs; [
    glib
    custom.mcmojave-cursors
    # theme packages
    (catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "compact";
      variant = "mocha";
    })
    bibata-cursors
    papirus-icon-theme
  ];

  services.greetd = {
    # Configuration for using with regreet -- only enable if regreet is enabled
    enable = config.programs.regreet.enable;
    settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${
        lib.getExe pkgs.cage
      } -s -m last -- ${lib.getExe config.programs.regreet.package} -l debug";
  };

  services.xserver.displayManager.gdm = {
    enable = false;
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

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal ];
  };

  # enable better codecs for bluetooth headset
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  hardware.pulseaudio.enable = lib.mkForce false;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  home-manager.users.max.xsession.enable = lib.mkForce false;
}
