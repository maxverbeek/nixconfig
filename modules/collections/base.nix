{
  # Every machine. The nix registry is deliberately absent: it needs flake
  # refs, and only the root has those, so hosts.nix sets it instead.
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
        users.max
      ];
    };
}
