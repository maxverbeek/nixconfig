{ ... }:
{
  flake.modules.nixos.personal = {
    nix.settings = {
      substituters = [
        # harmonia on the VPS, over tailscale; pre-builds land there nightly
        "http://scopecreep:5000"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        # printed by secrets/harmonia-signing-key.sh
        "scopecreep-1:PASTE_PUBLIC_KEY_HERE"
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
}
