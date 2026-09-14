{ config, my, ... }:
{
  configurations.hosts.scopecreep.module =
    {
      modulesPath,
      my,
      pkgs,
      ...
    }:
    {
      imports = with my.modules.nixos; [
        collections.base
        config.flake.modules.nixos.base

        collections.server
        network.hetzner-cloudinit
        services.n8n
        services.webdav
        services.feedbackers
        services.breadhero
        services.huurhunter
        services.copd
        services.harmonia

        my.modules.external.disko
        config.flake.diskoConfigurations.scopecreep

        # Decrypts secrets/*.age to /run/agenix at activation, using the host's
        # ssh key. Recipients are managed in /secrets.nix + /publickeys.nix.
        my.modules.external.agenix

        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      environment.systemPackages = [
        my.pkgs.wrapped.nvim
        # Bare packages, not the development collection: its live symlinks
        # point at the nixconfig repo root, which is not checked out on this host.
        my.pkgs.claude-code
        my.pkgs.wrapped.herdr
      ];

      # Weekday 08:00 claude run. Runs as max so it picks up the OAuth session
      # in ~/.claude; a system unit would have no credentials.
      systemd.user.timers.claude-daily = {
        description = "Weekday claude prompt";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "Mon..Fri *-*-* 08:00:00";
          Persistent = true;
        };
      };

      systemd.user.services.claude-daily = {
        description = "Weekday claude prompt";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "%h";
          ExecStart = "${my.pkgs.claude-code}/bin/claude -p 'Say good morning.'";
        };
      };

      # User units need a login-less session to survive; without this the timer
      # only exists while max is logged in over ssh.
      users.users.max.linger = true;

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
