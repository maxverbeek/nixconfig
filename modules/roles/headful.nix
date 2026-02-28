{ config, ... }:
{
  flake.modules.nixos.headful =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        ags
        fonts
        greeter
        networkmanager
        # hyprland
        niri
        screenlocker
        xdg
      ];

      users.users.max.extraGroups = [ "video" ];
    };

  flake.modules.homeManager.headful =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        ags
        hyprland
        niri
        playerctld
        polkit
        rofi
        screenlocker
        swww
        walker
        waybar
      ];
    };
}
