return {
  s(
    "nixmod",
    fmt(
      [[
{{ config, lib, ... }}:
let
  cfg = config.roles.{role};
in
{{
  options = {{
    enable = lib.mkEnableOption "Enable {desc} module";
  }};

  config = lib.mkIf cfg.enable {{
    {configBody}
  }};
}}
]],
      {
        role = i(1, "template"),
        desc = rep(1),
        configBody = i(2),
      }
    )
  ),
}
