{ config, ... }:
{
  flake.modules.homeManager.headful =
    { pkgs, ... }:
    let
      theme = config.flake.lib.theme;

      # Where the active variant is recorded. Runtime state, not store state:
      # apps that can't be signalled (barbell) watch this file instead.
      state = "\${XDG_RUNTIME_DIR:-/tmp}/${theme.statePath}";

      variantScript = name: variant: ''
        ${pkgs.dconf}/bin/dconf write $KEY "'${variant.scheme}'"

        # foot holds both palettes; the signal picks one. It then notifies
        # subscribed apps (mode 2031), and nvim re-queries the background
        # colour and flips `background` on its own -- no nvim config at all.
        # Signals are per-process, so every open terminal gets it.
        # SIGUSR1 = colors-dark, SIGUSR2 = colors-light.
        ${pkgs.procps}/bin/pkill -${if name == "dark" then "USR1" else "USR2"} foot || true

        printf '{"variant":"%s"}\n' ${name} > "${state}"
      '';
    in
    {
      home.packages = [
        (pkgs.writeShellScriptBin "theme-toggle" ''
          set -eu
          KEY=/org/gnome/desktop/interface/color-scheme

          case "''${1:-toggle}" in
            dark)  want=dark  ;;
            light) want=light ;;
            toggle)
              # An unset key reads as empty, which is neither variant. Treat
              # that as dark so the first toggle goes somewhere visible.
              if [ "$(${pkgs.dconf}/bin/dconf read $KEY)" = "'${theme.variants.light.scheme}'" ]; then
                want=dark
              else
                want=light
              fi
              ;;
            *) echo "usage: theme-toggle [toggle|dark|light]" >&2; exit 2 ;;
          esac

          if [ "$want" = dark ]; then
            ${variantScript "dark" theme.variants.dark}
          else
            ${variantScript "light" theme.variants.light}
          fi
        '')
      ];
    };
}
