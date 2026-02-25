{ config, ... }:
{
  flake.modules.nixos.networked =
    { lib, ... }:
    {
      # DNS resolution with Cloudflare fallback
      services.resolved = {
        enable = true;
        fallbackDns = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };

      # can override with mkForce
      networking.firewall.enable = lib.mkDefault true;
    };
}
