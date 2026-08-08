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

        # Global alias: -oenv anywhere in a command becomes a kubectl
        # go-template flag rendering a secret's .data as sourceable dotenv
        # export lines. The -- is required for an alias name starting with -.
        alias -g -- -oenv="-o go-template='{{range \$k,\$v := .data}}export {{\$k}}={{\$v | base64decode}}{{\"\n\"}}{{end}}'"
      '';
    };
}
