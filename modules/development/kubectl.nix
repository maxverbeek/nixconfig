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
      '';
    };
}
