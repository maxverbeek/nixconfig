{ ... }:
{
  flake.modules.nixos.personal = {
    nix.settings = {
      substituters = [
        # harmonia on the VPS, over tailscale; pre-builds land there nightly
        "http://scopecreep:5000"
      ];
      trusted-public-keys = [
        # printed by secrets/harmonia-signing-key.sh
        "scopecreep-1:jnrTBDq0e8LRrfiEdWPnAPdyA16FjVQgPzhg4QjebfY="
      ];

      # dont force using cache, fall back to rebuilds if cache is down
      connect-timeout = 3;
      download-attempts = 1;
      stalled-download-timeout = 15; # seconds
      fallback = true;
    };
  };
}
