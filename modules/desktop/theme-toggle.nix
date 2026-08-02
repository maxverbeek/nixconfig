{ config, ... }:
let
  theme = config.flake.lib.theme;
in
{
  flake.modules.homeManager.headful =
    { pkgs, lib, config, ... }:
    let
      # Where the active variant is recorded. Runtime state, not store state:
      # apps that can't be signalled (barbell) watch this file instead.
      state = "\${XDG_RUNTIME_DIR:-/tmp}/${theme.statePath}";

      key = "/org/gnome/desktop/interface/color-scheme";

      # Every module's contribution, in one attrset-ordered script per variant.
      variantScript =
        name:
        lib.concatStrings (
          lib.mapAttrsToList (_: f: f (theme.variants.${name} // { inherit name; })) config.theme.onSwitch
        );
    in
    {
      # Apps register how they follow a theme switch instead of this file
      # knowing about every app. nvim is the deliberate exception: it re-themes
      # itself from the terminal (mode 2031) and needs no entry here.
      options.theme.onSwitch = lib.mkOption {
        type = lib.types.attrsOf (lib.types.functionTo lib.types.lines);
        default = { };
        description = ''
          Shell snippets run by theme-toggle when the theme changes. Each
          function receives the chosen variant from flake.lib.theme.variants,
          plus `name` ("dark" | "light").
        '';
      };

      config = {
        # The switcher's own two duties: the desktop-wide dconf key
        # (GTK4/libadwaita and the portal follow it) and the state file.
        theme.onSwitch.dconf =
          { scheme, ... }:
          ''
            ${pkgs.dconf}/bin/dconf write ${key} "'${scheme}'"
          '';
        theme.onSwitch.state =
          { name, ... }:
          ''
            printf '{"variant":"%s"}\n' ${name} > "${state}"
          '';

        home.packages = [
          (pkgs.writeShellScriptBin "theme-toggle" ''
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
              *) echo "usage: theme-toggle [toggle|dark|light]" >&2; exit 2 ;;
            esac

            if [ "$want" = dark ]; then
              ${variantScript "dark"}
            else
              ${variantScript "light"}
            fi
          '')
        ];
      };
    };
}
