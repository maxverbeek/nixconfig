{ ... }:
{
  flake.modules.nixos.sshd =
    { ... }:
    {
      services.openssh = {
        enable = true;

        hostKeys = [
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];

        settings = {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = false;
        };
      };
    };
}
