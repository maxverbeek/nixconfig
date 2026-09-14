{ config, my, ... }:
{
  configurations.hosts.desknix.module =
    { ... }:
    {
      imports = [
        my.modules.nixos.collections.base
        my.modules.nixos.collections.workstation
        my.modules.nixos.collections.development

        # Roles
        config.flake.modules.nixos.base

        # Host-specific modules
        config.flake.modules.nixos.nvidia

        # Hardware
        ./_hardware-configuration.nix
      ];

      # Boot
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.memtest86.enable = true;
      boot.loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      boot.supportedFilesystems = [ "ntfs" ];

      # Networking
      networking.hostName = "desknix";
      networking.hostId = "aa111111";
      networking.extraHosts = ''
        127.0.0.1 keycloak
      '';
      networking.firewall.enable = false;
      networking.useDHCP = false;
      networking.interfaces.enp0s31f6.useDHCP = true;

      # Time (dual-boot with Windows)
      time.hardwareClockInLocalTime = true;

      # Hardware
      hardware.cpu.intel.updateMicrocode = true;
      hardware.graphics.enable = true;

      # X server (keyboard config)
      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          options = "eurosign:e";
        };
        autoRepeatDelay = 250;
        autoRepeatInterval = 50;
      };

      # Docker
      virtualisation.docker.storageDriver = "overlay2";

      system.stateVersion = "21.05";
    };
}
