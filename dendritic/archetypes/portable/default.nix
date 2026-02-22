{ ... }:
{
  # The portable archetype represents laptop-specific features:
  # battery, brightness, TLP, fingerprint, etc.
  # Individual features are in separate files.

  flake.modules.nixos.portable =
    { pkgs, ... }:
    {
      # Battery monitoring
      services.upower.enable = true;

      # Brightness control
      programs.light.enable = true;

      # Touchpad support
      services.libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.disableWhileTyping = true;
      };

      # Tailscale VPN
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "both";
      };
    };
}
