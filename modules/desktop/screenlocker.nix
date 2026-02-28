{ ... }:
{
  flake.modules.nixos.screenlocker = {
    security.pam.services.swaylock = { };
  };

  flake.modules.homeManager.screenlocker =
    { pkgs, ... }:
    let
      lock = pkgs.writeScriptBin "lock" ''
        #!${pkgs.bash}/bin/bash
        exec ${pkgs.swaylock-effects}/bin/swaylock -S --effect-pixelate 20 $@
      '';
      inactiveInterval = 5 * 60; # seconds, ISO27001 compliant
    in
    {
      home.packages = [
        lock
      ];

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = inactiveInterval - 10;
            command = "${lock}/bin/lock --grace 10";
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "${lock}/bin/lock";
          }
          {
            event = "lock";
            command = "${lock}/bin/lock";
          }
        ];
      };
    };
}
