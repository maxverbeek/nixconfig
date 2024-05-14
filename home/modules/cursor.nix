{ config, lib, ... }:
let cfg = config.modules.cursor;
in {
  options.modules.cursor = {
    enable = lib.mkEnableOption "custom cursor";

    package = lib.mkOption {
      type = lib.types.package;
      description = "Cursor package type";
      example = lib.literalExpression "pkgs.custom.mcmojave-cursors";
    };

    name = lib.mkOption {
      type = lib.types.str;
      description = "Cursor theme name";
    };

    size = lib.mkOption {
      type = lib.types.int;
      description = "Cursor size";
    };

    xcursor = lib.mkEnableOption "xcursor";
    hyprcursor = lib.mkEnableOption "hyprcursor";
  };

  config = lib.mkIf (cfg.enable) {
    assertions = [{
      assertion = cfg.xcursor != cfg.hyprcursor;
      message =
        "one of modules.cursor.xcursor or modules.cursor.hyprcursor must be enabled";
    }];

    home.packages = [ cfg.package ];

    home.file.".local/share/icons/${cfg.name}" = if cfg.hyprcursor then {
      source = "${cfg.package}/share/icons/${cfg.name}";
    } else
      { };

    home.sessionVariables = let

      xcursors = lib.attrsets.optionalAttrs (cfg.xcursor) {
        XCURSOR_THEME = cfg.name;
        XCURSOR_SIZE = cfg.size;
      };
      hyprcursors = lib.attrsets.optionalAttrs (cfg.hyprcursor) {
        HYPRCURSOR_THEME = cfg.name;
        HYPRCURSOR_SIZE = cfg.size;
      };
    in xcursors // hyprcursors;
  };
}
