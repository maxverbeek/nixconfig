{
  wrappers.configured.wlr-which-key =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.wlr-which-key ];

      # Only the settings that differ from wlr-which-key's own defaults
      # (src/config.rs): upstream ships "monospace 10", an opaque #282828ff
      # background, border_width 4 and corner_r 20. Everything else the old
      # home-manager module emitted matched upstream already.
      settings = {
        font = "JetBrainsMono Nerd Font 12";
        background = "#282828d0";
        border_width = 2;
        corner_r = 10;

        menu = [
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
            key = "f";
            desc = "Files (nautilus)";
            cmd = "nautilus";
          }
          {
            key = "t";
            desc = "Toggle theme (light/dark)";
            cmd = "theme-toggle";
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
