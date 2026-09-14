{
  nixos.hosts.desknix =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        collections.base
        collections.workstation
        collections.development

        hardware.nvidia
        ./_hardware.nix
      ];

      # Boot
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.memtest86.enable = true;
      boot.loader.efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      boot.supportedFilesystems = [ "ntfs" ];

      networking.hostId = "aa111111";
      networking.extraHosts = ''
        127.0.0.1 keycloak
      '';
      networking.firewall.enable = false;
      networking.useDHCP = false;
      networking.interfaces.enp0s31f6.useDHCP = true;

      # Windows on the other partition keeps the RTC in local time.
      time.hardwareClockInLocalTime = true;

      hardware.cpu.intel.updateMicrocode = true;
      hardware.graphics.enable = true;

      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          options = "eurosign:e";
        };
        autoRepeatDelay = 250;
        autoRepeatInterval = 50;
      };

      virtualisation.docker.storageDriver = "overlay2";

      system.stateVersion = "21.05";
    };
}
