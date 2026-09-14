{
  nixos.services.clamav = {
    services.clamav.daemon.enable = true;
  };
}
