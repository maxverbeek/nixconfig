{ ... }:
{
  flake.modules.nixos.base =
    { pkgs, lib, ... }:
    {
      nix = {
        package = pkgs.nixVersions.stable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        settings.trusted-users = [ "@wheel" ];
        settings.auto-optimise-store = true;

        gc = {
          automatic = true;
          dates = "weekly";
          options = lib.mkDefault "--delete-older-than 30d";
        };
      };

      programs.nix-ld.enable = true;
      programs.nh.enable = true;
    };
}
