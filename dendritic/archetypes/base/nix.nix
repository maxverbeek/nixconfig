{ ... }:
{
  flake.modules.nixos.nix-config =
    { pkgs, ... }:
    {
      nix = {
        package = pkgs.nixVersions.stable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        settings.trusted-users = [ "@wheel" ];
      };

      programs.nix-ld.enable = true;
      programs.nh.enable = true;
    };
}
