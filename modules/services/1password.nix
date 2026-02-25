{ ... }:
{
  flake.modules.nixos._1password =
    { pkgs, ... }:
    {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "max" ];
      };

      security.polkit.enable = true;

      environment.etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            chromium
            zen
            .zen-wrapped
          '';
          mode = "0755";
        };
      };

      environment.systemPackages = [ pkgs.xsel ];
    };
}
