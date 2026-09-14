{
  nixos.system.cachix = {
    nix.settings = {
      substituters = [
        # harmonia on the VPS, over tailscale; pre-builds land there nightly
        "http://scopecreep:5000"
      ];
      trusted-public-keys = [
        # printed by secrets/harmonia-signing-key.sh
        "scopecreep-1:jnrTBDq0e8LRrfiEdWPnAPdyA16FjVQgPzhg4QjebfY="
      ];

      # Fall back to rebuilding rather than hanging when the cache is down.
      connect-timeout = 3;
      download-attempts = 1;
      stalled-download-timeout = 15; # seconds
      fallback = true;
    };
  };
}
