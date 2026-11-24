{
  nixos.system.cachix = {
    nix.settings = {
      substituters = [
        # harmonia on the VPS, over tailscale; pre-builds land there nightly
        "http://scopecreep:5000"
      ];
      trusted-public-keys = [
        # printed from secrets/harmonia-signing-key.age
        "scopecreep-1:jnrTBDq0e8LRrfiEdWPnAPdyA16FjVQgPzhg4QjebfY="
      ];

      # Fall back to rebuilding rather than hanging when the cache is down.
      # Bounds DNS too: MagicDNS can take several seconds on a flaky network.
      connect-timeout = 10;
      download-attempts = 1;
      stalled-download-timeout = 15; # seconds
      fallback = true;

      # scopecreep GCs weekly; the 30-day default keeps serving narinfos for
      # deleted paths, so clients 404 on the NAR instead of asking again.
      narinfo-cache-positive-ttl = 3600;
    };
  };
}
