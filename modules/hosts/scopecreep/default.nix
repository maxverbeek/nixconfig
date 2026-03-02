{ config, inputs, ... }:
{
  configurations.hosts.scopecreep.module =
    { modulesPath, pkgs, ... }:
    {
      imports = [
        config.flake.modules.nixos.locale
        config.flake.modules.nixos.nix-config
        config.flake.modules.nixos.registry

        config.flake.modules.nixos.networked
        config.flake.modules.nixos.server
        config.flake.modules.nixos.hetzner-tailscale-cloudinit

        # User "max" (home-manager + base HM role: zsh, starship, fzf)
        config.flake.modules.nixos.max

        inputs.disko.nixosModules.disko
        config.flake.diskoConfigurations.scopecreep

        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      home-manager.users.max.home.packages = [
        pkgs.self.nvim
      ];

      users.users.max.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBmyftE9tuFUn/8m03M6aS0okxA7B1QFBxZNhP4CZ8F"
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
