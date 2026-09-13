# Shard: imported with no arguments, so the outer structure is a plain attrset
# and only the leaf is a module function (docs/wiring.md §4).
#
# Deliberate stub proving ROUTE 1; Phase 4 ports the real config from
# modules/development/git.nix into it.
{
  wrappers.config.git =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.git ];

      settings.user.name = "Max Verbeek";
    };
}
