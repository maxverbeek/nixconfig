# modules/

Every file below this directory is a **shard**: a plain attrset, three levels
deep, `<class>.<namespace>.<name>`, whose leaf is an ordinary module function.
`modules.nix` at the repository root walks the tree with `importSharded 3` and
aggregates every leaf into one virtual module at `my.modules.<class>.<ns>.<name>`.
Several files may declare the same leaf and are merged: a host's generated
`hardware.nix` and its `disko.nix` sit next to `default.nix` and declare
`nixos.hosts.<name>` themselves. There are no underscore files and no path
imports.

```nix
# modules/services/docker.nix declares exactly nixos.services.docker
{
  nixos.services.docker =
    { my, pkgs, ... }:
    {
      virtualisation.docker.enable = true;
      users.users.max.extraGroups = [ "docker" ];
    };
}
```

The outer attrset is imported with no arguments, so the namespace tree is known
before anything is evaluated; `my`, `pkgs`, `lib`, `config` arrive at the leaf
through specialArgs. A shard therefore cannot read flake inputs or build a
derivation, and must not try: wiring lives in the root files only (`default.nix`
knot, `modules.nix`, `packages.nix`, `hosts.nix`, `meta.nix`, `lib.nix`).

## Two groupings, one job each

A directory says **what a thing is**. A collection says **who wants it**. They
are never mixed: no directory is named after a machine or a role, and no leaf
knows which hosts import it.

| Namespace | Holds | Examples |
| --------- | ----- | -------- |
| `system/` | the OS itself | `nix`, `locale`, `fonts`, `xdg`, `cache` (the `my.cachePackages` option), `vps` |
| `hardware/` | drivers and device support | `pipewire`, `bluetooth`, `nvidia`, `fingerprint`, `tlp`, `laptop` |
| `network/` | connectivity | `networkmanager`, `tailscale`, `dns`, `nordlynx`, `hetzner-cloudinit` |
| `programs/` | things a person runs, incl. their user units | `zsh`, `git`, `niri`, `claude`, `steam`, `"1password"` |
| `services/` | daemons the machine runs | `docker`, `sshd`, `harmonia`, `huurhunter`, `n8n` |
| `users/` | accounts | `max` |
| `collections/` | named import lists | `base`, `workstation`, `development`, `laptop`, `server` |
| `hosts/` | one machine each | `desknix`, `thinkpad`, `scopecreep` |
| `wrappers/` | the `wrappers` class: programs built with their config | `modules/*` are wrapper module definitions; `configured/*` are instances and become `my.pkgs.wrapped.*` |

Rules of thumb:

- One file, one leaf, one concern, named after the program. A capability name
  only where several programs make one thing (`programs.lock`, `programs.terminal`).
- A collection file contains nothing but `imports = with my.modules.nixos; [ ... ]`.
  Collection names are the interface hosts depend on, so there are few of them.
- A host is identity plus a short import list: collections, a few leaves, boot,
  disks, `stateVersion`. `hostName` is the attribute name (`hosts.nix`).
- `programs/` is flat and long on purpose: one directory answers "how is X
  configured?" for every X.
- Namespaces are a closed list. Adding one is a change to `docs/structure.md`
  and `docs/wiring.md`, not a directory you create in passing.

## Where things come from

- Repo packages: `my.pkgs.<name>` (`packages/definitions/`), wrapped programs
  `my.pkgs.wrapped.<name>`, the second nixpkgs `my.pkgs.unstable.<name>`. No
  `pkgs.self`, `pkgs.custom`, `pkgs.unstable`, no overlays on hosts.
- Packages from other flakes: `my.pkgs.<name>` via `fromInputs` in `packages.nix`.
- Third-party NixOS modules: `imports = [ my.modules.external.<name> ]`, wired
  once in `modules.nix` (walker, stalker, disko, agenix, breadhero, ...).
- Plain data (repo root path, theme, the huurhunter FIP list): `my.meta.*`.
- Something the VPS should pre-build for the other machines:
  `my.cachePackages.<name> = my.pkgs.<name>;` in the leaf that uses it. ROUTE 4 in
  `packages.nix` folds every host's `my.cachePackages` into `my.pkgs.cache`, which
  harmonia's nightly names as `github:maxverbeek/nixconfig#cache`.
- Impure, live-editable config (niri's kdl, the wallpapers, the agents' shared
  files) is read from the working tree at `my.meta.repoRoot`; moving such a
  directory dangles symlinks on the running system until the next rebuild.

## Recipes

- **New program**: `programs/<name>.nix` declaring `nixos.programs.<name>`, then
  add it to the collection that wants it, or to one host's list. Enabling
  claude on the VPS is one line in `hosts/scopecreep/default.nix`.
- **New wrapped program**: `wrappers/configured/<name>.nix` declaring
  `wrappers.configured.<name>` (import an upstream `wlib.wrapperModules.<name>`
  or a local definition from `wrappers/modules/<name>.nix`); it appears as
  `my.pkgs.wrapped.<name>` and `nix build .#wrapped.<name>`.
- **New host**: `hosts/<name>/default.nix` declaring `nixos.hosts.<name>`, with
  the generated hardware config next to it as `hardware.nix` declaring the same
  leaf; it appears as `nixosConfigurations.<name>`.
- **Restructuring** (moving a leaf between files or collections) must not change
  what a host gets: evaluate each host with `nix.registry = lib.mkForce { }` and
  compare `toplevel.drvPath`; if a hash moves, the derivation graphs may differ
  only by permutations of the same multisets (module merge order). The full
  method is `docs/structure.md` rule 8.

Longer form, gitignored and only in the main checkout: `docs/wiring.md` (the
rules), `docs/structure.md` (the map and the proof method),
`docs/desired-state.md` (one exemplar per pattern).
