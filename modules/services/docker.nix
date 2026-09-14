{
  nixos.services.docker =
    { my, pkgs, ... }:
    {
      virtualisation.docker = {
        enable = true;
        package = my.pkgs.unstable.docker.override { buildxSupport = true; };
      };

      users.users.max.extraGroups = [ "docker" ];

      # Let containers reach the host via host.docker.internal -> host-gateway:
      # 172.16/12 is the container subnet, 172.17.0.1 the host gateway.
      networking.firewall.extraCommands = ''
        iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      '';
    };
}
