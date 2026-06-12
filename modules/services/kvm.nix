{ ... }:
{
  flake.modules.nixos.development =
    { pkgs, ... }:
    {
      virtualisation.libvirtd.enable = true;
      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [
        virt-manager
      ];

      users.users.max.extraGroups = [ "libvirtd" ];
    };
}
