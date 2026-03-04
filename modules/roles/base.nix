{ ... }:
{
  # Module content is now defined directly in the individual files
  # (locale.nix, nix.nix, registry.nix, shell.nix, tailscale.nix, ssh.nix)
  # which all set flake.modules.nixos.base / flake.modules.homeManager.base
}
