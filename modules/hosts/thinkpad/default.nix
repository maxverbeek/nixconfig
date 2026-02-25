{
  config,
  ...
}:
{
  configurations.hosts.thinkpad.module =
    { pkgs, lib, ... }:
    {
      imports = [
        # User "max" (includes home-manager wiring)
        config.flake.modules.nixos.max

        # Archetypes
        config.flake.modules.nixos.base
        config.flake.modules.nixos.headful
        config.flake.modules.nixos.portable

        # Host-specific modules with enable options
        config.flake.modules.nixos.kvm
        config.flake.modules.nixos.nvidia
        config.flake.modules.nixos.fingerprint

        # Hardware
        ./_hardware-configuration.nix
      ];

      # Host-specific configuration
      # Boot
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.luks.devices.root = {
        device = "/dev/disk/by-uuid/6e465077-1649-4e33-a5bf-55274047905c";
        preLVM = true;
        allowDiscards = true;
      };
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Networking
      networking.hostName = "thinkpad";
      networking.networkmanager.enable = true;
      networking.firewall.allowedTCPPorts = [
        3000
        3100
        3200
        8080
      ];
      networking.extraHosts = ''
        49.12.21.124 retriever.dev.legalmike.ai
        127.0.0.1 keycloak
      '';

      # Allow docker bridge traffic
      networking.firewall.extraCommands = ''
        iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      '';

      # Hardware
      hardware.graphics.enable = true;
      hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      hardware.firmware = with pkgs; [
        linux-firmware
        unstable.sof-firmware
      ];

      # Pipewire (unstable for better hardware support)
      services.pipewire.package = pkgs.unstable.pipewire;
      services.pipewire.enable = true;
      services.pipewire.audio.enable = true;
      services.pipewire.alsa.enable = true;

      # DNS
      services.resolved = {
        enable = true;
        fallbackDns = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };

      # Udev rules for keyboards
      services.udev.packages = [
        pkgs.via
        pkgs.qmk-udev-rules
      ];

      # Docker with buildx
      virtualisation.docker.package = pkgs.unstable.docker.override { buildxSupport = true; };

      # Custom modules
      modules.kvm2.enable = true;
      modules.kvm2.home.minikube.enable = true;
      modules.fingerprint.enable = true;

      # ClamAV
      services.clamav.daemon.enable = true;

      # Steam
      programs.steam.enable = true;
      environment.systemPackages = with pkgs; [
        alsa-ucm-conf
        steamcmd
        steam-tui
      ];

      system.stateVersion = "24.11";
    };
}
