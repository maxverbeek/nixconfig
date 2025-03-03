# https://github.com/NixOS/nixpkgs/issues/10001
{ config, lib, ... }:
{
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks =
    let
      networkConfig = {
        DHCP = "yes";
        DNSSEC = "yes";
        DNSOverTLS = "yes";
        DNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    in
    {
      # Config for all useful interfaces
      "40-wired" = {
        enable = true;
        name = "en*";
        inherit networkConfig;
        dhcpV4Config.RouteMetric = 1024; # Better be explicit
      };
      "40-wireless" = {
        enable = true;
        name = "wl*";
        inherit networkConfig;
        dhcpV4Config.RouteMetric = 2048; # Prefer wired
      };
    };

  # Wait for any interface to become available, not for all
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    ""
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];

  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp4s0";
}
