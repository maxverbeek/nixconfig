{ ... }:
{
  flake.modules.nixos.development =
    { pkgs, ... }:
    {
      environment.systemPackages = [
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
    };
}
