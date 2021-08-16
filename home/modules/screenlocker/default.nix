{ pkgs, config, ... }:
{
  imports = [ ./module.nix ];

  config = {
    services.my-screen-locker = {
      enable = config.device.withScreenLocker;
      lockCmd = ''
        ${pkgs.i3lock-fancy}/bin/i3lock-fancy -p
      '';
      inactiveInterval = 5; # time in minutes, 5 is required by ISO27001
      detectAudio = false;
      detectFullScreen = true;
      detectWebcam = true;
      detectSleep = true;
    };
  };
}
