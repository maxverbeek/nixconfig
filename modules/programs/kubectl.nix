{
  nixos.programs.kubectl =
    { my, pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.kubectl
        pkgs.kubectl-cnpg
        pkgs.cmctl
        pkgs.k9s
        pkgs.kubeseal
        (my.pkgs.unstable.wrapHelm my.pkgs.unstable.kubernetes-helm {
          plugins = [ my.pkgs.unstable.kubernetes-helmPlugins.helm-diff ];
        })
        pkgs.dyff
      ];
    };
}
