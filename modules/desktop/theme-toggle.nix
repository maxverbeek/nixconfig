{ ... }:
{
  flake.modules.homeManager.headful =
    { pkgs, config, ... }:
    {
      home.packages = [
        (pkgs.writeShellScriptBin "theme-toggle" ''
          set -eu
          KEY=/org/gnome/desktop/interface/color-scheme

          case "''${1:-toggle}" in
            dark)  scheme=prefer-dark  ;;
            light) scheme=prefer-light ;;
            toggle)
              # An unset key reads as empty, which is neither — treat it as dark
              # so the first toggle goes to light rather than a no-op.
              if [ "$(${pkgs.dconf}/bin/dconf read $KEY)" = "'prefer-light'" ]; then
                scheme=prefer-dark
              else
                scheme=prefer-light
              fi
              ;;
            *) echo "usage: theme-toggle [toggle|dark|light]" >&2; exit 2 ;;
          esac

          ${pkgs.dconf}/bin/dconf write $KEY "'$scheme'"

          # GTK4/libadwaita and the portal follow the key above. GTK3 only reads
          # settings.ini, so it needs the equivalent bool written separately.
          # Home Manager owns that file as a store symlink, hence the rewrite.
          ini="${config.xdg.configHome}/gtk-3.0/settings.ini"
          if [ -e "$ini" ]; then
            [ "$scheme" = "prefer-dark" ] && want=1 || want=0
            tmp=$(mktemp)
            ${pkgs.gnused}/bin/sed \
              "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$want/" \
              "$ini" > "$tmp"
            # Replace the symlink with a real file; HM restores it on activation.
            rm -f "$ini" && mv "$tmp" "$ini"
          fi
        '')
      ];

      # Seeds the GTK3 key so the sed above has a line to rewrite.
      gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    };
}
