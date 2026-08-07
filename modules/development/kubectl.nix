{ ... }:
{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.kubectl
        pkgs.kubectl-cnpg
        pkgs.cmctl
        pkgs.k9s
        pkgs.kubeseal
        (pkgs.unstable.wrapHelm pkgs.unstable.kubernetes-helm {
          plugins = [ pkgs.unstable.kubernetes-helmPlugins.helm-diff ];
        })
        pkgs.dyff
      ];

      programs.zsh.initContent = ''
        source <(kubectl completion zsh)
        source <(helm completion zsh)
        source <(helm diff completion zsh)

        # Typing -oenv<space> expands to a kubectl -o go-template flag that
        # renders a secret's .data as sourceable dotenv export lines.
        expand-oenv() {
          if [[ $LBUFFER == *-oenv ]]; then
            LBUFFER="''${LBUFFER%-oenv}-o go-template='{{range \$k,\$v := .data}}export {{\$k}}={{\$v | base64decode}}{{\"\n\"}}{{end}}'"
          fi
          zle self-insert
        }
        zle -N expand-oenv
        bindkey ' ' expand-oenv
      '';
    };
}
