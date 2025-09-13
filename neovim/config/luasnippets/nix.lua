return {
  s(
    "nixmod",
    fmt(
      [[
{{ config, lib, ... }}:
let
  cfg = config.{}.{}; 
in
{{
  options.{}.{} = {{
    enable = lib.mkEnableOption "Enable {} module";
  }};

  config = lib.mkIf cfg.enable {{
    {}
  }};
}}
]],
      {
        i(2, "template"),
        i(1, "roles"),
        rep(2),
        rep(1),
        rep(1),
        i(3),
      }
    )
  ),
}
