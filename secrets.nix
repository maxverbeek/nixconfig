# agenix recipient manifest, derived from secrets/default.nix. Only read by the
# `agenix` CLI (edit/rekey time), never by the flake. Run agenix from the repo
# root: `agenix -e secrets/<name>.age`.
let
  keys = import ./publickeys.nix;
  secrets = import ./secrets;
  recipients = secret: [ keys.max ] ++ map (host: keys.${host}) (secret.hosts or [ "scopecreep" ]);
in
builtins.listToAttrs (
  map (name: {
    name = "secrets/${baseNameOf secrets.${name}.file}";
    value.publicKeys = recipients secrets.${name};
  }) (builtins.attrNames secrets)
)
