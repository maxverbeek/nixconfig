{ config, inputs, ... }:
{
  configurations.hosts.scopecreep.module =
    { modulesPath, ... }:
    {
      imports = [
        config.flake.modules.nixos.locale
        config.flake.modules.nixos.nix-config
        config.flake.modules.nixos.registry

        config.flake.modules.nixos.networked
        config.flake.modules.nixos.server
        config.flake.modules.nixos.hetzner-tailscale-cloudinit

        inputs.disko.nixosModules.disko
        config.flake.diskoConfigurations.scopecreep

        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      boot.loader.grub.efiSupport = true;
      boot.loader.grub.efiInstallAsRemovable = true;

      networking.hostName = "scopecreep";

      # Allow all traffic on tailscale, deny everything on public interfaces
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      services.openssh.openFirewall = false;

      system.stateVersion = "25.11";
    };
}
