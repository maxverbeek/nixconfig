# The plain source trees from flake.lock, for evaluating without the flake.
# fetchTarball checks the narHash of the unpacked tree, which is what the lock
# records, so these are the store paths the flake inputs resolve to as well.
# Flake-shaped inputs are not resolved here: that would mean implementing
# flakes, and flake.nix already exists for them.
{ lockFile }:
let
  lock = builtins.fromJSON (builtins.readFile lockFile);

  fetch =
    name:
    let
      locked = lock.nodes.${lock.nodes.root.inputs.${name}}.locked;
    in
    builtins.fetchTarball {
      url = "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
      sha256 = locked.narHash;
    };
in
builtins.listToAttrs (
  map
    (name: {
      inherit name;
      value = fetch name;
    })
    [
      "nixpkgs"
      "unstable"
      "wrappers"
      "adw-catppuccin"
    ]
)
