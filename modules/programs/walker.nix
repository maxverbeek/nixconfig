{
  nixos.programs.walker =
    {
      my,
      pkgs,
      config,
      ...
    }:
    let
      elephantpkg = pkgs.symlinkJoin {
        name = "elephant";
        paths = [
          my.pkgs.elephant
          my.pkgs.elephant-gitlab
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
      # elephant follows our nixpkgs, so walker.cachix.org can't serve it
      cachePackages.elephant = my.pkgs.elephant;
      cachePackages.elephant-gitlab = my.pkgs.elephant-gitlab;

      # walker's nixos module imports elephant's, so services.elephant comes along.
      # nixpkgs ships its own, much thinner services.elephant (no providers, no
      # settings, no .so delivery); drop it so the flake's module owns the option.
      disabledModules = [ "services/misc/elephant.nix" ];
      imports = [ my.modules.external.walker ];

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

      # services.elephant.providers is an enum of upstream's built-in providers,
      # so the out-of-tree gitlab provider can't go through it. Its .so is linked
      # into /etc/xdg/elephant/providers the same way the module links the rest;
      # elephant scans every <xdg config dir>/elephant for *.so, so it gets loaded.
      environment.etc."xdg/elephant/providers/gitlab.so".source =
        "${elephantpkg}/lib/elephant/providers/gitlab.so";

      programs.walker = {
        enable = true;

        elephant = {
          package = elephantpkg;
          providers = defaultProviders;
        };

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

      # Both modules refuse to install the daemons (walker's runAsService is
      # unsupported, and it sets services.elephant.installService = false), so
      # the two user units are written out by hand.
      systemd.user.services.elephant = {
        description = "Elephant launcher backend";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
        restartTriggers = map (p: config.environment.etc."xdg/elephant/providers/${p}.so".source) (
          defaultProviders ++ [ "gitlab" ]
        );
        serviceConfig = {
          Type = "simple";
          ExecStart = "${config.services.elephant.package}/bin/elephant";
          # Clean up socket on stop
          ExecStopPost = "${pkgs.coreutils}/bin/rm -f /tmp/elephant.sock";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };

      systemd.user.services.walker = {
        description = "Walker - Application Runner";
        after = [
          "graphical-session.target"
          "elephant.service"
        ];
        requires = [ "elephant.service" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
        restartTriggers = [ config.environment.etc."xdg/walker/config.toml".source ];
        serviceConfig = {
          ExecStart = "${config.programs.walker.package}/bin/walker --gapplication-service";
          Restart = "on-failure";
        };
      };
    };
}
