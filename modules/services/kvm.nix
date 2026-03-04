{ ... }:
{
  flake.modules.nixos.development =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      virtualisation.libvirtd.enable = true;
      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [
        virt-manager
        docker-machine-kvm2
      ];

      users.users.max.extraGroups = [ "libvirtd" ];
    };

  flake.modules.homeManager.development =
    { pkgs, ... }:
    {
      home.file.".minikube/bin/docker-machine-driver-kvm2".source =
        "${pkgs.docker-machine-kvm2}/bin/docker-machine-driver-kvm2";
    };
}
