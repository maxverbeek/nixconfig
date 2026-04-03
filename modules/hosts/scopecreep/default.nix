{ config, inputs, ... }:
let
  modules = config.flake.modules.nixos;
in
{
  configurations.hosts.scopecreep.module =
    { modulesPath, pkgs, ... }:
    {
      imports = [
        modules.base

        modules.server
        modules.hetzner-tailscale-cloudinit
        modules.n8n
        modules.webdav
        modules.feedbackers

        # User "max" (home-manager + base HM role: zsh, starship, fzf)
        modules.max

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

      users.users.max.extraGroups = [ "podman" ];

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
