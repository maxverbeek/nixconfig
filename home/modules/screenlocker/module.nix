{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.services.my-screen-locker;

  xssLock = "${pkgs.systemd}/bin/loginctl lock-session $XDG_SESSION_ID";
in
{

  options.services.my-screen-locker = {
    enable = mkEnableOption "screenlocker for X session using xidlehook";

    lockCmd = mkOption {
      type = types.str;
      description = "Locker command to run.";
      example = "\${pkgs.i3lock}/bin/i3lock -n -c 000000";
    };

    inactiveInterval = mkOption {
      type = types.int;
      default = 10;
      description = ''
        Inactive time interval in minutes after which session will be locked.
        The minimum is 1 minute, and the maximum is 1 hour.
        See <link xlink:href="https://linux.die.net/man/1/xautolock"/>.
      '';
    };

    xssLockExtraOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra command-line arguments to pass to <command>xss-lock</command>.
      '';
    };

    detectSleep = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to reset timers when awaking from sleep.
      '';
    };

    detectFullScreen = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Detect if an application is running in fullscreen, and do not
        lock the screen if so.
      '';
    };

    detectAudio = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Detect if an application is playing audio, and do not lock the
        screen if so.
      '';
    };

    detectWebcam = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Detect if the webcam is being used, and do not lock the screen
        if so.
      '';
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = config.services.screen-locker.enable == false;
        message = "The default `services.screen-locker` is incompatible with this custom `services.my-screen-locker`";
      }
    ];

    systemd.user.services.xautolock-session = {
      Unit = {
        Description = "xautolock, session locker service";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        # TODO: add socket communication so timers can be triggered manually
        # (nicer way to prevent double locking)
        ExecStart = concatStringsSep " " (
          [ "${pkgs.xidlehook}/bin/xidlehook" ]
          ++ optional cfg.detectFullScreen "--not-when-fullscreen"
          ++ optional cfg.detectWebcam "--not-when-webcam"
          ++ optional cfg.detectSleep "--detect-sleep"
          ++ [ "--timer ${toString (cfg.inactiveInterval * 60)} '${xssLock}' ''" ]
        );
      };
    };

    systemd.user.services.xss-lock = {
      Unit = {
        Description = "xss-lock, session locker service";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = concatStringsSep " " (
          [
            "${pkgs.xss-lock}/bin/xss-lock"
            "-s \${XDG_SESSION_ID}"
          ]
          ++ cfg.xssLockExtraOptions
          ++ [ "-- ${cfg.lockCmd}" ]
        );
      };
    };
  };
}
