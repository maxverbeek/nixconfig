{ ... }:
{
  flake.modules.nixos.fingerprint =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.fprintd = {
        enable = true;
        tod.enable = true;
        tod.driver = pkgs.libfprint-2-tod1-goodix-550a;
      };

      security.pam.services.sudo.fprintAuth = false;
      security.pam.services.login.fprintAuth = false;
    };
}
