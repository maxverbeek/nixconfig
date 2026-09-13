{ config, ... }:
let
  theme = config.flake.lib.theme;
in
{
  flake.modules.nixos.headful =
    { my, pkgs, ... }:
    {
      environment.systemPackages = [
        my.pkgs.wrapped.foot
        my.pkgs.wrapped.alacritty
        my.pkgs.not
      ];

      # Live foots switch palette on the signal (and notify apps via mode 2031,
      # which is how nvim re-themes). Future foots read the rewritten include.
      theme.onSwitch.foot =
        { name, ... }:
        ''
          ${pkgs.procps}/bin/pkill -${if name == "dark" then "USR1" else "USR2"} foot || true
          printf '[main]\ninitial-color-theme=%s\n' ${name} > "$HOME/${theme.footThemeIni}"
        '';

      # A missing include is FATAL to foot, so the file must exist before the
      # first toggle ever runs. tmpfiles `f` writes the argument only when the
      # file does not exist; theme-toggle owns it from then on.
      systemd.user.tmpfiles.users.max.rules = [
        "f %h/${theme.footThemeIni} 0644 - - - [main]\\ninitial-color-theme=dark"
      ];
    };
}
