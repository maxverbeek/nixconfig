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

      # A path string, not a package: a package is rewritten to
      # /run/current-system/sw/bin/zsh, which is the plain unwrapped pkgs.zsh.
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
