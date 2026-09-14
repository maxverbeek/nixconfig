{
  wrappers.configured.niri =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.niri ];

      # `content`, not `path`: the module only validates and hot-reloads
      # `constructFiles.generatedConfig`, and feeds `"config.kdl".path` to
      # NIRI_CONFIG unchecked. Setting `content` makes our kdl the generated
      # config, so `niri validate` actually checks it.
      "config.kdl".content = builtins.readFile ../../desktop/niri/niri-config.kdl;
    };
}
