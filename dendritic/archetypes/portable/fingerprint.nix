{ ... }:
{
  flake.modules.nixos.fingerprint =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.fingerprint;
    in
    {
      options.modules.fingerprint = {
        enable = lib.mkEnableOption "Enable fingerprint module";
      };

      config = lib.mkIf cfg.enable {
        services.fprintd = {
          enable = true;
          tod.enable = true;
          tod.driver = pkgs.libfprint-2-tod1-goodix-550a;
        };

        security.pam.services.sudo.fprintAuth = false;
        security.pam.services.login.fprintAuth = false;
      };
    };
}
