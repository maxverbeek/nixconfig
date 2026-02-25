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

        # Roles
        config.flake.modules.nixos.base
        config.flake.modules.nixos.networked
        config.flake.modules.nixos.multimedia
        config.flake.modules.nixos.personal
        config.flake.modules.nixos.headful
        config.flake.modules.nixos.development
        config.flake.modules.nixos.docker
        config.flake.modules.nixos.portable
        config.flake.modules.nixos.gaming

        # Host-specific modules
        config.flake.modules.nixos.clamav
        config.flake.modules.nixos.keyboards
        config.flake.modules.nixos.kvm
        config.flake.modules.nixos.fingerprint

        # Hardware
        ./_hardware-configuration.nix
      ];

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

      system.stateVersion = "24.11";
    };
}
