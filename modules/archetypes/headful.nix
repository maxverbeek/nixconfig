{ config, ... }:
{
  flake.modules.nixos.headful =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        ags
        greeter
        # hyprland
        niri
        xdg
      ];
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
