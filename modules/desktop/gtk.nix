{ config, inputs, ... }:
{
  flake.modules.homeManager.personal =
    { pkgs, lib, ... }:
    let
      theme = config.flake.lib.theme;
      catppuccinCss = flavor: "${inputs.adw-catppuccin}/adw/themes/${flavor}/catppuccin-${flavor}-mauve.css";
      kanagawa = pkgs.custom.kanagawa-nvim.colors.term;
      kanagawaCss = pkgs.runCommand "adw-kanagawa-wave.css" { } ''
        cp ${catppuccinCss "mocha"} "$out"
        substituteInPlace "$out" \
          --replace-fail "Catppuccin mocha theme" "Kanagawa Wave theme" \
          --replace-fail "#cba6f7" "${kanagawa.normal.blue}" \
          --replace-fail "#f38ba8" "${kanagawa.normal.red}" \
          --replace-fail "#a6e3a1" "${kanagawa.bright.green}" \
          --replace-fail "#cdd6f4" "${kanagawa.bright.white}" \
          --replace-fail "#313244" "#2A2A37" \
          --replace-fail "#1e1e2e" "${kanagawa.extended.background}" \
          --replace-fail "#11111b" "${kanagawa.extended.darker}"
      '';
      colorCss = palette: if palette == "kanagawa" then kanagawaCss else catppuccinCss palette;
      darkCss = colorCss theme.variants.dark.gtk.palette;
      lightCss = colorCss theme.variants.light.gtk.palette;
    in
    {
      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus";
        };

        gtk3 = {
          theme = null;
          extraCss = ''
            @import url("theme.css");
          '';
        };

        gtk4 = {
          theme = null;
          extraCss = ''
            @import url("theme.css");
          '';
        };
      };

      home.packages = [ pkgs.adw-gtk3 ];

      home.activation.linkGtkColorTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ${pkgs.gnugrep}/bin/grep -qx 'initial-color-theme=light' "$HOME/${theme.footThemeIni}" 2>/dev/null; then
          css=${lightCss}
        else
          css=${darkCss}
        fi
        run ${pkgs.coreutils}/bin/ln -sfn "$css" "$HOME/.config/gtk-3.0/theme.css"
        run ${pkgs.coreutils}/bin/ln -sfn "$css" "$HOME/.config/gtk-4.0/theme.css"
      '';

      theme.onSwitch.gtk =
        { gtk, ... }:
        ''
          ${pkgs.coreutils}/bin/ln -sfn ${colorCss gtk.palette} "$HOME/.config/gtk-3.0/theme.css"
          ${pkgs.coreutils}/bin/ln -sfn ${colorCss gtk.palette} "$HOME/.config/gtk-4.0/theme.css"
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'${gtk.themeName}'"
        '';

      fonts.fontconfig = {
        enable = true;
        defaultFonts.serif = [ "Noto Serif" ];
        defaultFonts.sansSerif = [ "Noto Sans" ];
      };
    };
}
