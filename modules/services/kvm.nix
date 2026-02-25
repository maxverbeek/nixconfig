{ ... }:
{
  flake.modules.nixos.kvm =
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

  flake.modules.homeMangager.kvm =
    { pkgs, ... }:
    {
      home.file.".minikube/bin/docker-machine-driver-kvm2".source =
        "${pkgs.docker-machine-kvm2}/bin/docker-machine-driver-kvm2";
    };
}
