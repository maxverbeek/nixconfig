{ config, ... }:
{
  flake.modules.nixos.server =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        sshd
      ];

      # Serial console for Hetzner web console
      boot.kernelParams = [ "console=ttyS0" ];

      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBmyftE9tuFUn/8m03M6aS0okxA7B1QFBxZNhP4CZ8F"
      ];

      services.fail2ban = {
        enable = true;
        bantime = "${toString (7 * 24)}h";
      };
    };
}
