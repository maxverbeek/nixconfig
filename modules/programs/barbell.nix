{
  nixos.programs.barbell =
    { my, pkgs, ... }:
    {
      my.cachePackages.barbell = my.pkgs.barbell;

      # The battery widget reads UPower over D-Bus.
      services.upower.enable = true;

      # jq and curl are barbell runtime deps: the Claude usage widget shells out
      # to both. On PATH so niri binds can say `barbell ipc call menu open`.
      environment.systemPackages = [
        my.pkgs.barbell
        pkgs.jq
        pkgs.curl
      ];

      # services.blueman.enable autostarts a tray applet barbell already
      # replaces. /etc/xdg wins over /run/current-system/sw/etc/xdg in
      # XDG_CONFIG_DIRS, so this hides just the applet.
      environment.etc."xdg/autostart/blueman.desktop".text = ''
        [Desktop Entry]
        Hidden=true
      '';

      systemd.user.services.barbell = {
        description = "barbell (quickshell) bar";
        wants = [ "niri.service" ];
        after = [ "niri.service" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${my.pkgs.barbell}/bin/barbell";
          Restart = "always";
          RestartSec = "1s";
        };
      };
    };
}
