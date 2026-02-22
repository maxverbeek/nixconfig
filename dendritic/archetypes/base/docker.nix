{ ... }:
{
  # NixOS: docker + KVM/libvirtd with option flags
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;
    users.users.max.extraGroups = [ "docker" ];
  };

  flake.modules.nixos.kvm =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.kvm2;
    in
    {
      options.modules.kvm2 = {
        enable = lib.mkEnableOption "KVM2 virtualisation";
        home.minikube.enable = lib.mkEnableOption "enable home-manager minikube support";
      };

      config = lib.mkIf cfg.enable {
        virtualisation.libvirtd.enable = true;
        programs.dconf.enable = true;
        environment.systemPackages = with pkgs; [
          virt-manager
          docker-machine-kvm2
        ];

        users.users.max.extraGroups = [ "libvirtd" ];

        home-manager.users.max = lib.mkIf cfg.home.minikube.enable {
          home.file.".minikube/bin/docker-machine-driver-kvm2".source =
            "${pkgs.docker-machine-kvm2}/bin/docker-machine-driver-kvm2";
        };
      };
    };
}
