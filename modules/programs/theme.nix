{
  nixos.programs.theme =
    {
      my,
      pkgs,
      lib,
      config,
      ...
    }:
    let
      theme = my.meta.theme;

      # Runtime state, not store state: apps that can't be signalled (barbell)
      # watch this file instead.
      state = "\${XDG_RUNTIME_DIR:-/tmp}/${theme.statePath}";

      key = "/org/gnome/desktop/interface/color-scheme";

      # Every module's contribution, in one attrset-ordered script per variant.
      variantScript =
        name:
        lib.concatStrings (
          lib.mapAttrsToList (_: f: f (theme.variants.${name} // { inherit name; })) config.my.theme.onSwitch
        );

      theme-toggle = pkgs.writeShellScriptBin "theme-toggle" ''
        set -eu

        case "''${1:-toggle}" in
          dark)  want=dark  ;;
          light) want=light ;;
          toggle)
            # An unset key reads as empty, which is neither variant. Treat
            # that as dark so the first toggle goes somewhere visible.
            if [ "$(${pkgs.dconf}/bin/dconf read ${key})" = "'${theme.variants.light.scheme}'" ]; then
              want=dark
            else
              want=light
            fi
            ;;
          current)
            # Re-apply what dconf already records, without toggling. Same
            # unset-reads-as-dark rule as above.
            if [ "$(${pkgs.dconf}/bin/dconf read ${key})" = "'${theme.variants.light.scheme}'" ]; then
              want=light
            else
              want=dark
            fi
            ;;
          *) echo "usage: theme-toggle [toggle|dark|light|current]" >&2; exit 2 ;;
        esac

        if [ "$want" = dark ]; then
          ${variantScript "dark"}
        else
          ${variantScript "light"}
        fi
      '';
    in
    {
      # Apps register how they follow a theme switch, so this file knows about
      # none of them. nvim is the exception: it re-themes itself from the
      # terminal (mode 2031) and needs no entry.
      #
      # KNOWN-BROKEN, not fixable here: Electron 39+ mishandles runtime
      # color-scheme changes on Wayland, so Slack and Obsidian only get the
      # theme right at startup. Upstream: electron/electron#48736.
      options.my.theme.onSwitch = lib.mkOption {
        type = lib.types.attrsOf (lib.types.functionTo lib.types.lines);
        default = { };
        description = ''
          Shell snippets run by theme-toggle when the theme changes. Each
          function receives the chosen variant from my.meta.theme.variants,
          plus `name` ("dark" | "light").
        '';
      };

      config = {
        # The switcher's own two duties: the desktop-wide dconf key
        # (GTK4/libadwaita and the portal follow it) and the state file.
        my.theme.onSwitch.dconf =
          { scheme, ... }:
          ''
            ${pkgs.dconf}/bin/dconf write ${key} "'${scheme}'"
          '';
        my.theme.onSwitch.state =
          { name, ... }:
          ''
            printf '{"variant":"%s"}\n' ${name} > "${state}"
          '';

        environment.systemPackages = [ theme-toggle ];

        # On login, re-apply the recorded variant: re-points the gtk theme.css
        # symlinks, rewrites foot's theme.ini, and seeds the state file barbell
        # watches, which lives in XDG_RUNTIME_DIR and so is empty after boot.
        systemd.user.services.theme-restore = {
          description = "Re-apply the recorded light/dark theme variant";
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${theme-toggle}/bin/theme-toggle current";
          };
        };
      };
    };
}
