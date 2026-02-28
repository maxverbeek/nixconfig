{ inputs, ... }:
{
  flake.modules.nixos.cachix = {
    nix.settings = {
      substituters = [
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
      ];

      trusted-public-keys = [
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      ];
    };
  };

  flake.modules.homeManager.walker =
    { pkgs, ... }:
    let
      elephantpkg = pkgs.symlinkJoin {
        name = "elephant";
        paths = [
          inputs.elephant.packages.${pkgs.stdenv.hostPlatform.system}.default
          inputs.elephant-gitlab.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };

      defaultProviders = [
        "bluetooth"
        "bookmarks"
        "calc"
        "clipboard"
        "desktopapplications"
        "files"
        "menus"
        "providerlist"
        "runner"
        "snippets"
        "symbols"
        "todo"
        "unicode"
        "websearch"
        "windows"
        "bitwarden"
        "1password"
        "nirisessions"
        "niriactions"
      ];
    in
    {
      imports = [ inputs.walker.homeManagerModules.default ];

      programs.elephant = {
        package = elephantpkg;
        providers = defaultProviders ++ [ "gitlab" ];
      };

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
