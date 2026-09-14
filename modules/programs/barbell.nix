{
  nixos.programs.barbell =
    { my, pkgs, ... }:
    {
      cachePackages.barbell = my.pkgs.barbell;

      # The battery widget reads UPower over D-Bus.
      services.upower.enable = true;

      # The wrapper is on PATH so niri binds can say `barbell ipc call menu
      # open` without knowing any store path.
      #
      # jq and curl are barbell runtime deps: the Claude usage widget shells
      # out to both to fetch rate-limit data. Its other externals need no
      # entry here — nmcli rides in with networking.networkmanager.enable and
      # `niri msg` with the compositor itself.
      environment.systemPackages = [
        my.pkgs.barbell
        pkgs.jq
        pkgs.curl
      ];

      # barbell has its own bluetooth UI. services.blueman.enable (bluetooth.nix)
      # ships a system-wide autostart for the tray applet alongside the
      # blueman-manager we do want; this /etc/xdg override hides just the
      # applet. /etc/xdg precedes /run/current-system/sw/etc/xdg in
      # XDG_CONFIG_DIRS, and the first hit wins.
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
