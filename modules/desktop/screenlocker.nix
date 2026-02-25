{ ... }:
{
  flake.modules.homeManager.screenlocker =
    { pkgs, ... }:
    let
      lockCmd = "${pkgs.swaylock}/bin/swaylock -fF";
      inactiveInterval = 5 * 60; # seconds, ISO27001 compliant
    in
    {
      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = inactiveInterval;
            command = lockCmd;
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = lockCmd;
          }
          {
            event = "lock";
            command = lockCmd;
          }
        ];
      };
    };
}
