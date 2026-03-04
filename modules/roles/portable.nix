{ ... }:
{
  flake.modules.nixos.portable =
    { ... }:
    {
      # Battery monitoring
      services.upower.enable = true;

      # Brightness control
      programs.light.enable = true;

      # Input device access
      users.users.max.extraGroups = [ "input" ];

      # Touchpad support
      services.libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.disableWhileTyping = true;
      };

      # Tailscale: allow acting as both subnet router and exit node
      services.tailscale.useRoutingFeatures = "both";
    };
}
