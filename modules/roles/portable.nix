{ ... }:
{
  flake.modules.nixos.portable =
    { pkgs, ... }:
    {
      # Battery monitoring
      services.upower.enable = true;

      # Brightness control
      environment.systemPackages = [ pkgs.brightnessctl ];
      services.udev.packages = [ pkgs.brightnessctl ];

      # Input device access (and brightnessctl backlight writes via video group)
      users.users.max.extraGroups = [ "input" "video" ];

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
