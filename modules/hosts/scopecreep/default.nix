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
        modules.breadhero
        modules.huurhunter
        modules.copd
        modules.harmonia

        # User "max" (home-manager + base HM role: zsh, starship, fzf)
        modules.max

        inputs.disko.nixosModules.disko
        config.flake.diskoConfigurations.scopecreep

        # Decrypts secrets/*.age to /run/agenix at activation, using the host's
        # ssh key. Recipients are managed in /secrets.nix + /publickeys.nix.
        inputs.agenix.nixosModules.default

        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      home-manager.users.max.home.packages = [
        pkgs.self.nvim
      ];

      users.users.max.openssh.authorizedKeys.keys = [
        (import ../../../publickeys.nix).max
      ];

      users.users.max.extraGroups = [ "podman" ];

      nixpkgs.hostPlatform = "x86_64-linux";

      boot.loader.grub.efiSupport = true;
      boot.loader.grub.efiInstallAsRemovable = true;
      # 256M ESP fits ~6 generations of kernel+initrd; cap well under that so a
      # rebuild can never fill /boot and lock itself out of fixing it.
      boot.loader.grub.configurationLimit = 3;

      networking.hostName = "scopecreep";

      # Allow all traffic on tailscale, deny everything on public interfaces
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      services.openssh.openFirewall = false;

      system.stateVersion = "25.11";
    };
}
