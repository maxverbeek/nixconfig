{
  nixos.hosts.thinkpad =
    {
      my,
      config,
      pkgs,
      ...
    }:
    {
      imports = with my.modules.nixos; [
        my.modules.external.agenix
        collections.base
        collections.workstation
        collections.development
        collections.laptop

        programs.steam
        services.clamav
        hardware.keyboards
        hardware.fingerprint
        network.nordlynx
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.luks.devices.root = {
        device = "/dev/disk/by-uuid/6e465077-1649-4e33-a5bf-55274047905c";
        preLVM = true;
        allowDiscards = true;
      };
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # No sshd here, so agenix decrypts with max's own key instead of a host key.
      age.identityPaths = [ "/home/max/.ssh/id_ed25519" ];
      age.secrets.nordlynx-key.file = ../../../secrets/nordlynx.key.age;
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
      # Subnet router and exit node.
      services.tailscale.useRoutingFeatures = "both";

      hardware.graphics.enable = true;
      hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      hardware.firmware = with pkgs; [
        linux-firmware
        my.pkgs.unstable.sof-firmware
      ];

      # unstable: this laptop's audio hardware needs a newer pipewire.
      services.pipewire.package = my.pkgs.unstable.pipewire;

      system.stateVersion = "24.11";
    };
}
