{
  wrappers.configured.niri =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.niri ];

      # The kdl stays where it is; see the hazard note in docs/wiring.md 6c.
      # `content`, not `path`: the module validates and hot-reloads
      # `constructFiles.generatedConfig`, and only feeds `"config.kdl".path`
      # to NIRI_CONFIG. Setting `content` makes our kdl the generated config,
      # so `niri validate` actually checks it and `path` defaults to it.
      "config.kdl".content = builtins.readFile ../../desktop/niri/niri-config.kdl;
    };
}
