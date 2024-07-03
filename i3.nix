{ config, pkgs, ... }:

let
  jbmono = pkgs.nerdfonts.override {
    fonts = [
      "JetBrainsMono"
      "Hermit"
    ];
  };
in
{
  config = {
    fonts.fonts = with pkgs; [
      hermit
      jbmono
    ];

    services.picom = {
      enable = true;
    };

    services.xserver = {
      enable = true;

      desktopManager.xterm.enable = false;

      displayManager = {
        defaultSession = "none+i3";

        lightdm.greeters.mini = {
          enable = true;
          user = "max";
        };
      };

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [ alacritty ];
        configFile = pkgs.writeText "i3-config" ''
          # Mod4 = windows key
          set $mod Mod4

          font pango:JetBrains Mono NerdFont 10

          set $ws1 "1"
          set $ws2 "2"
          set $ws3 "3"
          set $ws4 "4"
          set $ws5 "5"

          bindsym $mod+w kill
          bindsym $mod+1 workspace number $ws1
          bindsym $mod+2 workspace number $ws2
          bindsym $mod+3 workspace number $ws3
          bindsym $mod+4 workspace number $ws4
          bindsym $mod+5 workspace number $ws5

          bindsym $mod+Shift+Escape i3-msg exit
          bindsym $mod+Return exec alacritty
        '';
      };
    };
  };
}
