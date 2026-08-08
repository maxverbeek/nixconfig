{ ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nix = {
        package = pkgs.nixVersions.stable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        settings.trusted-users = [ "@wheel" ];
        settings.auto-optimise-store = true;
      };

      programs.nix-ld.enable = true;
      programs.nh.enable = true;
    };
}
