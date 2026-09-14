{
  nixos.hardware.laptop =
    { pkgs, ... }:
    {
      services.upower.enable = true;

      environment.systemPackages = [ pkgs.brightnessctl ];
      services.udev.packages = [ pkgs.brightnessctl ];

      # video: brightnessctl writes the backlight through that group.
      users.users.max.extraGroups = [
        "input"
        "video"
      ];

      services.libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.disableWhileTyping = true;
      };
    };
}
