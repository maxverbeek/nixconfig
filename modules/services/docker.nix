{
  flake.modules.nixos.docker =
    { pkgs, ... }:
    {
      virtualisation.docker = {
        enable = true;
        package = pkgs.unstable.docker.override { buildxSupport = true; };
      };

      users.users.max.extraGroups = [ "docker" ];

      # Allow docker bridge traffic through host.docker.internal -> host-gateway
      # 172.16/12 is the subnet typically used by containers, and 172.17.0.1 is typically the gateway to the host
      networking.firewall.extraCommands = ''
        iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      '';
    };
}
