{ config, inputs, ... }:
let
  theme = config.flake.lib.theme;
  catppuccinCss =
    flavor: "${inputs.adw-catppuccin}/adw/themes/${flavor}/catppuccin-${flavor}-mauve.css";
in
{
  flake.modules.nixos.personal =
    { my, pkgs, ... }:
    let
      kanagawa = my.pkgs.kanagawa-nvim.colors.term;
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

      # was gtk.gtk{3,4}.extraCss. The palette is a sibling symlink rather than
      # an import of a store path, so a toggle re-points it without a rebuild.
      gtkCss = pkgs.writeText "gtk.css" ''
        @import url("theme.css");
      '';
    in
    {
      # was gtk.iconTheme (package + name + the dconf key HM's gtk module set).
      # GTK reads settings.ini from XDG_CONFIG_DIRS, and /etc/xdg is first.
      environment.systemPackages = [
        pkgs.papirus-icon-theme
        pkgs.adw-gtk3
      ];

      environment.etc."xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-icon-theme-name=Papirus
      '';
      environment.etc."xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-icon-theme-name=Papirus
      '';

      programs.dconf.profiles.user.databases = [
        { settings."org/gnome/desktop/interface".icon-theme = "Papirus"; }
      ];

      systemd.user.tmpfiles.users.max.rules = [
        # gtk.css is ours and always current: L+ replaces whatever is there.
        "L+ %h/.config/gtk-3.0/gtk.css - - - - ${gtkCss}"
        "L+ %h/.config/gtk-4.0/gtk.css - - - - ${gtkCss}"
        # theme.css is theme-toggle's to own, so seed it only when missing (L,
        # not L+) -- otherwise every login would stomp a toggle back to dark.
        # theme-restore re-points it for the recorded variant at login, which
        # also covers the css store path changing under a rebuild.
        "L %h/.config/gtk-3.0/theme.css - - - - ${darkCss}"
        "L %h/.config/gtk-4.0/theme.css - - - - ${darkCss}"
      ];

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
