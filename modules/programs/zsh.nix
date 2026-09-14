{
  nixos.programs.zsh =
    { pkgs, my, ... }:
    let
      secrand = pkgs.writeScriptBin "secrand" ''
        #!${pkgs.ruby}/bin/ruby
        require 'securerandom'

        puts SecureRandom.hex(if ARGV[0].nil? then 64 else ARGV[0].to_i end)
      '';

      gitlabcivars = pkgs.writeScriptBin "gitlabcivars" ''
        #!${pkgs.bash}/bin/bash

        if [ ! -f ~/.gitlab_pat ]; then
          echo "File ~/.gitlab_pat not found"
          exit 1
        fi

        GITLAB_TOKEN=$(cat ~/.gitlab_pat) ${pkgs.glab}/bin/glab variable export | ${pkgs.jq}/bin/jq -r ".[] | (.key + \"=\" + .value)"
      '';

      jqd = pkgs.writeScriptBin "jqd" ''
        #!${pkgs.bash}/bin/bash

        exec jq 'map_values(.| @base64d)'
      '';
    in
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
        secrand
        gitlabcivars
        jqd
        pkgs.fzf
        pkgs.zoxide
        pkgs.starship
      ];
    };
}
