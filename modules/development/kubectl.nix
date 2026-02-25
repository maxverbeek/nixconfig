{ ... }:
{
  flake.modules.homeManager.kubectl =
    { pkgs, lib, ... }:
    {
      home.packages = [
        pkgs.kubectl
        pkgs.kubectl-cnpg
        pkgs.cmctl
        pkgs.k9s
        pkgs.kubeseal
        (pkgs.wrapHelm pkgs.kubernetes-helm {
          plugins = [ pkgs.kubernetes-helmPlugins.helm-diff ];
        })
      ];

      programs.zsh.initContent = ''
        source <(kubectl completion zsh)
        source <(helm completion zsh)
        source <(helm diff completion zsh)
      '';
    };
}
