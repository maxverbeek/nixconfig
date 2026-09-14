{
  nixos.programs.bitwarden =
    { my, pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.bws
        # unstable: 0.18 adds the `bws://SERVER_BASE@PROJECT` EU override; stable
        # 0.10 always hits bitwarden.com (US) and fails auth against our EU vault.
        my.pkgs.unstable.secretspec
      ];
    };
}
