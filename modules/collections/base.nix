{
  # Every machine. `system.registry` joins this list when hosts move to
  # hosts.nix -- it still needs flake refs, so it stays flake-parts shaped and
  # reaches hosts through the surviving `flake.modules.nixos.base` namespace.
  nixos.collections.base =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        system.nix
        system.locale
        system.cache
        programs.zsh
        programs.ssh
        programs.bitwarden
        network.dns
        network.tailscale
        network.mullvad
        network.nordvpn
        network.cloudflared
        users.max
      ];
    };
}
