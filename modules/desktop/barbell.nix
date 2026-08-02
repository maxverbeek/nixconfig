{ inputs, ... }:
{
  # The battery widget reads UPower over D-Bus.
  flake.modules.nixos.headful = {
    services.upower.enable = true;
  };

  flake.modules.homeManager.headful =
    { pkgs, ... }:
    {
      # The wrapper is on PATH so niri binds can say `barbell ipc call menu
      # open` without knowing any store path.
      #
      # jq and curl are barbell runtime deps: the Claude usage widget shells
      # out to both to fetch rate-limit data. Its other externals need no
      # entry here — nmcli rides in with networking.networkmanager.enable and
      # `niri msg` with the compositor itself.
      home.packages = [
        inputs.barbell.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.jq
        pkgs.curl
      ];

      # barbell has its own bluetooth UI. services.blueman.enable (bluetooth.nix)
      # ships a system-wide autostart for the tray applet alongside the
      # blueman-manager we do want; this user-level override hides just the
      # applet.
      xdg.configFile."autostart/blueman.desktop".text = ''
        [Desktop Entry]
        Hidden=true
      '';

      systemd.user.services.barbell = {
        Unit = {
          Description = "barbell (quickshell) bar";
          Wants = [ "niri.service" ];
          After = [ "niri.service" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${inputs.barbell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/barbell";
          Restart = "always";
          RestartSec = "1s";
        };
      };
    };
}
