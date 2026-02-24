# Dendritic NixOS Configuration

## Architecture

This configuration uses the **dendritic pattern**: a flake-parts setup where
`import-tree` auto-discovers every `.nix` file in the `dendritic/` directory.
Each file is a flake-parts module that contributes to typed module namespaces
(`flake.modules.nixos.*` and `flake.modules.homeManager.*`).

### Three-tier composition

```
hosts → archetypes → features
```

- **Hosts** (`hosts/`) define `nixosConfigurations` and select which archetypes
  and standalone modules to include.
- **Archetypes** (`archetypes/`) are directories of related features. Each
  archetype has a `default.nix` that serves as its **composition point**.
- **Features** are individual `.nix` files within an archetype directory.

### Feature pattern: named modules

Every feature defines its own named module. A feature file never contributes
directly to an archetype namespace — it always defines its own:

```nix
# archetypes/headful/niri.nix
{ ... }:
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.niri ];
      # ...
    };

  flake.modules.homeManager.niri =
    { config, ... }:
    {
      home.file.".config/niri/config.kdl".source = ...;
    };
}
```

A feature file can define both a NixOS and a home-manager module. This keeps
all configuration for a given piece of software in one place, organized by
feature rather than by implementation layer.

### The `default.nix` composition point

Each archetype's `default.nix` is the **only place** that composes features
into an archetype. It uses `imports` to pull in named feature modules:

```nix
# archetypes/headful/default.nix
{ config, ... }:    # <-- flake-parts config (outer scope)
{
  flake.modules.nixos.headful =
    { ... }:        # <-- NixOS module args (must NOT shadow outer config)
    {
      imports = with config.flake.modules.nixos; [
        niri
        greeter
        hyprland
      ];
    };

  flake.modules.homeManager.headful =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        niri
        rofi
        waybar
      ];
    };
}
```

**Critical**: The `imports` list references `config.flake.modules.*` from the
**flake-parts** `config` (the outer module argument). The inner NixOS/HM
module must use `{ ... }:` (not `{ config, ... }:`) to avoid shadowing the
flake-parts config. Using the NixOS `config` in `imports` causes infinite
recursion.

### Archetype independence

Archetypes do **not** import each other. Hosts explicitly list every archetype
they need:

```nix
modules = [
  config.flake.modules.nixos.base
  config.flake.modules.nixos.headful
  config.flake.modules.nixos.portable
  config.flake.modules.nixos.kvm
  config.flake.modules.nixos.nvidia
];
```

This avoids duplicate module imports (NixOS cannot deduplicate function-based
modules) and makes the host file the single source of truth for what's
included.

### No `mkEnableOption` / `mkIf`

Modules are not toggled on/off with enable flags. A feature is included by
being imported in an archetype's `default.nix`, and an archetype is included
by a host. If a feature is imported, it's active.

### File conventions

- **`_` prefix** — files and directories starting with `_` are ignored by
  `import-tree` (used for hardware configs, helper libs, non-module Nix files).
- **Non-`.nix` files** — naturally ignored by `import-tree` (e.g.
  `niri-config.kdl`).
- **`default.nix`** — composition point for archetypes; defines the archetype
  namespace and imports named feature modules.

## Directory structure

```
flake.nix                           # Uses import-tree ./dendritic
dendritic/
  flake-parts.nix                   # Bootstrap: systems, flakeModules.modules
  nixpkgs/                          # Overlay pipeline, registry, cachix
  archetypes/
    base/                           # Shared by all hosts
    headful/                        # Graphical desktop (wayland, WMs, bar, greeter)
    development/                    # Dev tools, editors, languages
    portable/                       # Laptop-specific (battery, touchpad, VPN)
  hosts/
    thinkpad/                       # nixosConfigurations.thinkpad
    desknix/                        # nixosConfigurations.desknix
  users/
    max.nix                         # User definition + HM wiring
  packages/
    neovim/                         # perSystem neovim packages
    _custom/                        # Legacy custom packages
  _overlays/                        # Legacy version overrides
  wallpapers/                       # Greeter wallpapers
```
