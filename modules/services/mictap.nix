{
  nixos.services.mictap =
    { my, ... }:
    {
      imports = [ my.modules.external.mictap-server ];

      services.mictap.server = {
        enable = true;
        # Only tailscale0 is a trusted interface; the port stays closed elsewhere.
        listen = "0.0.0.0:8765";
        outputDir = "/srv/data/webdav/max/mictap";
        # rclone's user, so Remotely Save uploads and mictap can overwrite each other's files.
        user = "webdav";
        group = "webdav";
      };
    };
}
