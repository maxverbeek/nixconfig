{ ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      services.tailscale.enable = true;
      # Let max toggle tailscale without sudo — `tailscale down` from the bar's
      # network menu is a prefs write, and those are root-or-operator only.
      services.tailscale.extraSetFlags = [ "--operator=max" ];
    };
}
