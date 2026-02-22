{ ... }:
{
  # Home-manager: xidlehook + xss-lock screen locker (X11 legacy)
  flake.modules.homeManager.screenlocker =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy -p";
      inactiveInterval = 5; # minutes, ISO27001 compliant
      xssLock = "${pkgs.systemd}/bin/loginctl lock-session $XDG_SESSION_ID";
    in
    {
      # Only activate when device.withScreenLocker is true
      systemd.user.services.xautolock-session = lib.mkIf config.device.withScreenLocker {
        Unit = {
          Description = "xautolock, session locker service";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = builtins.concatStringsSep " " [
            "${pkgs.xidlehook}/bin/xidlehook"
            "--not-when-fullscreen"
            "--not-when-webcam"
            "--detect-sleep"
            "--timer ${toString (inactiveInterval * 60)} '${xssLock}' ''"
          ];
        };
      };

      systemd.user.services.xss-lock = lib.mkIf config.device.withScreenLocker {
        Unit = {
          Description = "xss-lock, session locker service";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = builtins.concatStringsSep " " [
            "${pkgs.xss-lock}/bin/xss-lock"
            "-s \${XDG_SESSION_ID}"
            "-- ${lockCmd}"
          ];
        };
      };
    };
}
