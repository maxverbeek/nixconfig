{
  nixos.users.max =
    { my, ... }:
    {
      environment.variables.EDITOR = "nvim";

      users.users.max = {
        isNormalUser = true;
        # A path, not the package: utils.toShellPath rewrites a shell *package*
        # to /run/current-system/sw/bin/zsh (the plain pkgs.zsh), so the wrapper
        # would never become the login shell. Paths pass through unchanged.
        shell = "${my.pkgs.wrapped.zsh}/bin/zsh";
        extraGroups = [ "wheel" ];
      };
    };
}
