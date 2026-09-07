{
  config,
  inputs,
  ...
}:
let
  modules = config.flake.modules.nixos;
  hmModules = config.flake.modules.homeManager;
in
{
  configurations.hosts.thinkpad.module =
    { config, pkgs, lib, ... }:
    {
      imports = [
        inputs.agenix.nixosModules.default
        # User "max" (includes home-manager wiring)
        modules.max

        # Roles
        modules.base
        modules.multimedia
        modules.personal
        modules.headful
        modules.development
        modules.docker
        modules.portable
        modules.gaming

        # Host-specific modules
        modules.clamav
        modules.keyboards
        modules.fingerprint
        modules.nordlynx

        # Hardware
        ./_hardware-configuration.nix
      ];

      # Desktop home-manager roles for max (on top of base from max.nix)
      home-manager.users.max.imports = with hmModules; [
        headful
        personal
        development
      ];

      home-manager.users.max.home.sessionVariables = {
        JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

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
      # No sshd here, so agenix decrypts with max's own key instead of a host key.
      age.identityPaths = [ "/home/max/.ssh/id_ed25519" ];
      age.secrets.nordlynx-key.file = ../../../secrets/nordlynx.key.age;
      # NordLynx as NM profiles, all off by default.
      services.nordlynx = {
        enable = true;
        mode = "networkmanager";
        privateKeyFile = config.age.secrets.nordlynx-key.path;
      };
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
