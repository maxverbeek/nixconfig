{
  nixos.network.dns =
    { lib, ... }:
    {
      services.resolved = {
        enable = true;
        settings.Resolve.FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };

      networking.firewall.enable = lib.mkDefault true;
    };
}
