{ config, ... }:
{
  flake.modules.nixos.portable =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        tlp
      ];

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

      # Tailscale VPN
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "both";
      };
    };
}
