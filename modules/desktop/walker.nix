{ inputs, ... }:
{
  flake.modules.homeManager.walker =
    { ... }:
    {
      imports = [ inputs.walker.homeManagerModules.default ];

      programs.walker = {
        enable = true;
        runAsService = true;

        config = {
          placeholders."default" = {
            input = "Search";
            list = "Example";
          };
          providers.prefixes = [
            {
              provider = "websearch";
              prefix = "+";
            }
            {
              provider = "providerlist";
              prefix = "_";
            }
            {
              provider = "gitlab";
              prefix = "~";
            }
          ];

          providers.actions.gitlab = [
            {
              action = "open";
              default = true;
              bind = "Return";
            }
            {
              action = "copy_url";
              label = "copy url";
              bind = "ctrl c";
            }
            {
              action = "refresh";
              label = "refresh";
              bind = "ctrl r";
              after = "AsyncReload";
            }
            {
              action = "erase_history";
              label = "clear hist";
              bind = "ctrl h";
              after = "AsyncReload";
            }
          ];

          keybinds = {
            quick_activate = [
              "F1"
              "F2"
              "F3"
            ];
            next = [
              "Down"
              "ctrl j"
            ];
            previous = [
              "Up"
              "ctrl k"
            ];
            left = [
              "Left"
              "ctrl h"
            ];
            right = [
              "Right"
              "ctrl l"
            ];
            down = [
              "Down"
              "ctrl j"
            ];
            up = [
              "Up"
              "ctrl k"
            ];
          };
        };

        themes = { };
      };
    };
}
