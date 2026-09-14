{
  # User "max": account, login shell, EDITOR.
  nixos.users.max =
    { my, ... }:
    {
      environment.variables.EDITOR = "nvim";

      users.users.max = {
        isNormalUser = true;
        # The path, not the package: NixOS's utils.toShellPath rewrites a shell
        # *package* to /run/current-system/sw/bin/zsh, which is the plain
        # pkgs.zsh that programs.zsh.enable puts in the system profile -- the
        # wrapper would never actually be the login shell. A path is passed
        # through unchanged.
        shell = "${my.pkgs.wrapped.zsh}/bin/zsh";
        extraGroups = [
          "wheel"
          "nordvpn"
        ];
      };
    };
}
