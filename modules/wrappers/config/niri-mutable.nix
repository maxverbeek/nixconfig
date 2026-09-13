{
  # Config read from the working tree: edit the kdl, niri reloads, no rebuild.
  wrappers.config.niri-mutable =
    { my, lib, ... }:
    {
      imports = [ my.modules.wrappers.config.niri ];

      # A string, not a path literal, so nothing is copied to the store.
      "config.kdl".path = lib.mkForce "${my.meta.repoRoot}/modules/desktop/niri/niri-config.kdl";

      # A working-tree path cannot be validated inside the build sandbox.
      disableConfigValidation = true;
    };
}
