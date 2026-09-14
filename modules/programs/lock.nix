{
  # No NixOS counterpart to home-manager's services.swayidle, so the user unit
  # is written out by hand here.
  nixos.programs.lock =
    { lib, pkgs, ... }:
    let
      lock = pkgs.writeScriptBin "lock" ''
        #!${pkgs.bash}/bin/bash
        exec ${pkgs.swaylock-effects}/bin/swaylock -S --effect-pixelate 50 $@
      '';
      inactiveInterval = 5 * 60; # seconds, ISO27001 compliant
      args = [
        "-w"
        "timeout"
        (toString (inactiveInterval - 10))
        "${lock}/bin/lock --grace 10"
        "before-sleep"
        "${lock}/bin/lock"
        "lock"
        "${lock}/bin/lock"
      ];
    in
    {
      security.pam.services.swaylock = { };

      environment.systemPackages = [
        lock
        pkgs.swayidle
      ];

      systemd.user.services.swayidle = {
        description = "Idle manager for Wayland";
        documentation = [ "man:swayidle(1)" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
        # swayidle runs its commands through "sh -c", so PATH needs a shell.
        path = [ pkgs.bash ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${lib.getExe pkgs.swayidle} ${lib.escapeShellArgs args}";
        };
      };
    };
}
