{ pkgs, config, ... }:
{
  services.screen-locker = {
    enable = config.device.withScreenLocker;
    lockCmd = ''
      ${pkgs.i3lock-fancy}/bin/i3lock-fancy -p
    '';
    inactiveInterval = 5; # time in minutes, 5 is required by ISO27001
  };
}
