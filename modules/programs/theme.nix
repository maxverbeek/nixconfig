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
      # Apps register how they follow a theme switch instead of this file
      # knowing about every app. nvim is the deliberate exception: it re-themes
      # itself from the terminal (mode 2031) and needs no entry here.
      #
      # KNOWN-BROKEN, not fixable here: Electron 39+ (Chromium 142) mishandles
      # runtime color-scheme changes on Linux/Wayland, so Slack and Obsidian get
      # the theme right at startup but wrong on live toggle (flash-then-revert).
      # The portal/dconf side is correct; the bug is inside Electron. Only a
      # restart re-detects. Upstream: electron/electron#48736.
      options.theme.onSwitch = lib.mkOption {
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

        environment.systemPackages = [ theme-toggle ];

        # On login, re-apply the recorded variant: this re-points the gtk
        # theme.css symlinks and rewrites foot's theme.ini for that variant,
        # replacing HM's activation-time linkGtkColorTheme. It also seeds the
        # runtime state file barbell watches, which lives in XDG_RUNTIME_DIR
        # and so is empty after every boot. dconf needs the session bus, which
        # user services have.
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
