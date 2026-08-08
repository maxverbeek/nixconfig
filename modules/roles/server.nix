{ config, ... }:
{
  flake.modules.nixos.server =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        sshd
        fail2ban
      ];

      environment.systemPackages = [ pkgs.git ];

      # Servers can be more aggressive than the 30d base default
      nix.gc.options = "--delete-older-than 14d";

      # Pull master and rebuild nightly; nixos-rebuild appends #$(hostname)
      system.autoUpgrade = {
        enable = true;
        flake = "github:maxverbeek/nixconfig";
        dates = "04:00";
        allowReboot = true;
      };

      # Serial console for Hetzner web console
      boot.kernelParams = [ "console=ttyS0" ];

      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBmyftE9tuFUn/8m03M6aS0okxA7B1QFBxZNhP4CZ8F"
      ];
    };
}
