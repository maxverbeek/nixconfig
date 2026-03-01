{ config, ... }:
{
  flake.modules.homeManager.wlr-which-key = {
    # this stuff is generic and exported on flake level as an extension type thing..
    imports = [ config.flake.homeModules.wlr-which-key ];

    programs.wlr-which-key = {
      enable = true;

      config.menu = [
        {
          key = "p";
          desc = "Open 1password";
          cmd = "1password";
        }
        {
          key = "l";
          desc = "Open S(l)ack";
          cmd = "slack";
        }
        {
          key = "n";
          desc = "Notes (obsidian)";
          cmd = "obsidian";
        }
        {
          key = "b";
          desc = "Browser (zen)";
          cmd = "zen-beta";
        }
        {
          key = "c";
          desc = "Open config files";
          submenu = [
            {
              key = "n";
              desc = "Nix";
              cmd = "foot -D ~/nixconfig nvim";
            }
          ];
        }
        {
          key = "s";
          desc = "Screen (share)";
          submenu = [
            {
              key = "s";
              desc = "Share current window";
              cmd = "niri msg action set-dynamic-cast-window";
            }
            {
              key = "m";
              desc = "Share current monitor";
              cmd = "niri msg action set-dynamic-cast-monitor";
            }
            {
              key = "c";
              desc = "Clear dynamic cast";
              cmd = "niri msg action clear-dynamic-cast-target";
            }
            {
              key = "1";
              desc = "Scale current output 1";
              cmd = "sh -c 'niri msg output $(niri msg -j focused-output | jq -r .name) scale 1'";
            }
            {
              key = "2";
              desc = "Scale current output 2";
              cmd = "sh -c 'niri msg output $(niri msg -j focused-output | jq -r .name) scale 2'";
            }
            {
              key = "5";
              desc = "Scale current output 1.5";
              cmd = "sh -c 'niri msg output $(niri msg -j focused-output | jq -r .name) scale 1.5'";
            }
          ];
        }
      ];
    };
  };
}
