# Resolves the plain source trees packages.nix needs straight from flake.lock,
# so `nix build -f . pkgs.wrapped.git` works without the flake.
#
# Only the four github-type inputs that are plain trees, never flakes: their
# outputs are never read, so fetching the tarball is enough. The narHash in the
# lock is the hash of the unpacked tree, which is exactly what fetchTarball
# checks, so these land on the same store paths the flake inputs do.
#
# Flake-shaped inputs (modules and packages from other flakes) exist only
# through flake.nix, deliberately: resolving those means implementing flakes.
# When flake.nix calls `import ./. inputs` its inputs shadow these per
# attribute; a bare `import ./. { }` gets them from the lock.
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
