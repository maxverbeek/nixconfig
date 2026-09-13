# Re-export of my.meta.theme; the theme itself is defined in meta.nix.
{ my, ... }:
{
  flake.lib.theme = my.meta.theme;
}
