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
        # Bare packages, not the development HM role: that role's live symlinks
        # point at the nixconfig repo root, which is not checked out on this host.
        pkgs.claude-code
        pkgs.self.herdr
      ];

      # Weekday 08:00 claude run. Runs as max so it picks up the OAuth session
      # in ~/.claude; a system unit would have no credentials.
      home-manager.users.max.systemd.user = {
        timers.claude-daily = {
          Unit.Description = "Weekday claude prompt";
          Timer = {
            OnCalendar = "Mon..Fri *-*-* 08:00:00";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
        services.claude-daily = {
          Unit.Description = "Weekday claude prompt";
          Service = {
            Type = "oneshot";
            WorkingDirectory = "%h";
            ExecStart = "${pkgs.claude-code}/bin/claude -p 'Say good morning.'";
          };
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
