{ config, ... }:
{
  configurations.hosts.desknix.module =
    { pkgs, ... }:
    {
      imports = [
        # User "max" (includes home-manager wiring)
        config.flake.modules.nixos.max

        # Archetypes
        config.flake.modules.nixos.base
        config.flake.modules.nixos.headful

        # Host-specific modules with enable options
        config.flake.modules.nixos.kvm
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
      networking.networkmanager.enable = true;
      networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
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

      # Services
      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          options = "eurosign:e";
        };
        videoDrivers = [ "nvidia" ];
        autoRepeatDelay = 250;
        autoRepeatInterval = 50;
      };

      services.printing.enable = true;
      services.gnome.gnome-keyring.enable = true;

      # Docker
      virtualisation.docker.storageDriver = "overlay2";

      # Custom modules
      modules.kvm2.enable = true;
      modules.kvm2.home.minikube.enable = true;

      # Extra system packages
      environment.systemPackages = with pkgs; [
        git
        killall
        vim
        nodejs
        yarn
      ];

      system.stateVersion = "21.05";
    };
}
