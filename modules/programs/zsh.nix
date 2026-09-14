{
  nixos.programs.zsh =
    { pkgs, my, ... }:
    {
      programs.zsh = {
        enable = true;
        # The wrapped zsh runs compinit itself.
        enableCompletion = false;
      };

      environment.pathsToLink = [ "/share/zsh" ];

      # chsh and anything that validates a login shell read /etc/shells. Listed
      # as a path for the same reason max's shell is: a package would be
      # rewritten to /run/current-system/sw/bin/zsh (the plain pkgs.zsh).
      environment.shells = [ "${my.pkgs.wrapped.zsh}/bin/zsh" ];

      # fzf, zoxide and starship must be on PATH: their init scripts (baked into
      # the zsh wrapper) call the binaries by name, and `fzf` is run directly.
      environment.systemPackages = [
        pkgs.fzf
        pkgs.zoxide
        pkgs.starship
      ];
    };
}
