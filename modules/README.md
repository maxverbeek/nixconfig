# Dendritic NixOS Configuration

## Architecture

This configuration uses the **dendritic pattern**: a flake-parts setup where
`import-tree` auto-discovers every `.nix` file in the `modules/` directory.
Each file is a flake-parts module that contributes to typed module namespaces
(`flake.modules.nixos.*` and `flake.modules.homeManager.*`).

### Three-tier composition

```
hosts -> roles -> modules
```

- **Hosts** (`hosts/`) define `nixosConfigurations` and compose roles and
  standalone modules.
- **Roles** (`roles/`) group related modules into composable units. Each role
  has a NixOS side and optionally a home-manager side.
- **Modules** are individual `.nix` files that configure a single piece of
  software or service.

### Design principles

1. **Roles should be small.** It is better to compose many small roles than to
   have a few large ones that are unusable in some contexts.
2. **Roles do not import each other.** Hosts explicitly list every role they
   need. This avoids duplicate module imports (NixOS cannot deduplicate
   function-based modules) and makes the host file the single source of truth.
3. **Host-specific config stays in the host.** Roles contain only config that
   is shared across multiple hosts or represents a logical concern. Hardware
   UUIDs, hostnames, interface names, and per-host overrides belong in the
   host file.
4. **No `mkEnableOption` / `mkIf` in roles.** A module is active when it is
   imported. Opt-in behavior is reserved for standalone modules (e.g. `kvm`,
   `fingerprint`) that use NixOS option flags.

## Roles

### `base` -- Minimal foundation

Safe for any NixOS machine, including headless servers and VPSs. Contains only
what you would expect from a freshly installed system with your Nix preferences.

| Layer            | Modules                                     |
|------------------|---------------------------------------------|
| **NixOS**        | `locale`, `nix-config`, `registry`, `shell` |
| **Home-Manager** | `shell`, `ssh`, `terminal`                  |

**What it provides:** Nix daemon config (flakes, nix-ld, nh), locale/timezone,
Zsh shell, nix registry entries, SSH host configs, terminal emulator configs.

### `networked` -- DNS and firewall

For any machine on a network. Sets up DNS resolution and firewall defaults.
Does **not** choose a network backend (NetworkManager vs systemd-networkd) --
that is determined by other roles or host config.

| Layer     | Config                                                                             |
|-----------|------------------------------------------------------------------------------------|
| **NixOS** | `services.resolved` (Cloudflare fallback DNS), `networking.firewall.enable = true` |

### `headful` -- Graphical desktop

Everything needed for an interactive graphical session: compositor, display
manager, fonts, NetworkManager, application launchers, status bar.

| Layer            | Modules                                                                                               |
|------------------|-------------------------------------------------------------------------------------------------------|
| **NixOS**        | `ags`, `fonts`, `greeter`, `networkmanager`, `niri`, `xdg`                                            |
| **Home-Manager** | `ags`, `hyprland`, `niri`, `playerctld`, `polkit`, `rofi`, `screenlocker`, `swww`, `walker`, `waybar` |

**Groups:** `video`

### `multimedia` -- Audio and Bluetooth

PipeWire audio stack and Bluetooth support. Separated from `headful` because
a graphical machine might not need audio (e.g. a kiosk), and a server might
want Bluetooth for specific hardware.

| Layer     | Modules                 |
|-----------|-------------------------|
| **NixOS** | `bluetooth`, `pipewire` |

**Groups:** `audio` (via pipewire), `bluetooth` (via bluetooth)

### `personal` -- Your preferences

Personal desktop preferences that don't belong on shared or work
infrastructure: password manager, printer support, Cachix caches, GTK theme.

| Layer            | Modules                           |
|------------------|-----------------------------------|
| **NixOS**        | `_1password`, `cachix`, `printer` |
| **Home-Manager** | `gtk`                             |

### `portable` -- Laptop power and input

Laptop-specific hardware management: battery, power profiles, touchpad,
brightness control, VPN.

| Layer | Modules / Config |
|---|---|
| **NixOS** | `tlp`, `services.upower`, `programs.light`, `services.libinput`, `services.tailscale` |

**Groups:** `input`

### `development` -- Developer tooling

Development tools, editors, language runtimes, and hardware access groups for
embedded work.

| Layer | Modules |
|---|---|
| **NixOS** | *(groups only)* |
| **Home-Manager** | `codex`, `dev-packages`, `direnv`, `git`, `kubectl`, `neovim`, `rstudio`, `vscode` |

**Groups:** `plugdev`, `dialout`, `adbusers`

### `docker` -- Container runtime

Standalone role for Docker. Separated from `development` because servers may
run containers without needing dev tooling.

| Layer | Config |
|---|---|
| **NixOS** | `virtualisation.docker.enable` |

**Groups:** `docker`

### `gaming` -- Steam and related

Gaming support. Only included on hosts where you actually play games.

| Layer | Config |
|---|---|
| **NixOS** | `programs.steam.enable`, `steamcmd`, `steam-tui`, `alsa-ucm-conf` |

## Standalone modules

These are not roles but individual feature modules. Some are included by roles,
others are listed directly in host imports (typically with `mkEnableOption`).

| Module | Included by | Description |
|---|---|---|
| `_1password` | personal | 1Password CLI + GUI |
| `bluetooth` | multimedia | Bluetooth hardware + Blueman |
| `cachix` | personal | Binary cache substituters |
| `clamav` | *(host)* | ClamAV antivirus daemon |
| `docker` | docker (role) | Docker engine |
| `fingerprint` | *(host, opt-in)* | Fingerprint reader (fprintd) |
| `fonts` | headful | System font packages |
| `gaming` | *(host)* | Steam + related packages |
| `greeter` | headful | Display manager (regreet/greetd) |
| `keyboards` | *(host)* | QMK/Via udev rules |
| `kvm` | *(host, opt-in)* | KVM/libvirt virtualisation |
| `locale` | base | Locale and timezone |
| `networkmanager` | headful | NetworkManager |
| `niri` | headful | Niri Wayland compositor |
| `nix-config` | base | Nix daemon settings |
| `nvidia` | *(host)* | NVIDIA GPU drivers |
| `pipewire` | multimedia | PipeWire audio stack |
| `printer` | personal | CUPS + Avahi printing |
| `registry` | base | Nix flake registry |
| `shell` | base | Zsh shell |
| `tlp` | portable | TLP power management |
| `xdg` | headful | XDG portals and MIME |

## Host composition examples

### Desktop workstation (desknix)

```nix
imports = [
  max
  # Roles
  base networked multimedia personal headful development docker
  # Host-specific
  nvidia kvm
  ./_hardware-configuration.nix
];
```

### Laptop (thinkpad)

```nix
imports = [
  max
  # Roles
  base networked multimedia personal headful development docker portable gaming
  # Host-specific
  clamav keyboards nvidia kvm fingerprint
  ./_hardware-configuration.nix
];
```

### Future: VPS / server

```nix
imports = [
  max
  # Roles
  base networked
  ./_hardware-configuration.nix
];
```

### Future: Build server

```nix
imports = [
  max
  # Roles
  base networked development docker
  ./_hardware-configuration.nix
];
```

## Module pattern

Every module defines its own named entry in the `flake.modules` namespace.
A module file never contributes directly to a role namespace -- it always
defines its own:

```nix
# modules/pipewire.nix
{ ... }:
{
  flake.modules.nixos.pipewire =
    { lib, ... }:
    {
      services.pipewire = { enable = true; ... };
      users.users.max.extraGroups = [ "audio" ];
    };
}
```

Roles then compose these named modules via `imports`:

```nix
# modules/roles/multimedia.nix
{ config, ... }:
{
  flake.modules.nixos.multimedia =
    { ... }:
    {
      imports = with config.flake.modules.nixos; [
        bluetooth
        pipewire
      ];
    };
}
```

**Critical**: The `imports` list references `config.flake.modules.*` from the
**flake-parts** `config` (the outer module argument). The inner NixOS/HM
module must use `{ ... }:` (not `{ config, ... }:`) to avoid shadowing the
flake-parts config, which causes infinite recursion.

## File conventions

- **`_` prefix** -- files and directories starting with `_` are ignored by
  `import-tree` (used for hardware configs, helper libs, non-module Nix files).
- **Non-`.nix` files** -- ignored by `import-tree`.
- **`roles/`** -- role composition files that group modules.
- **`hosts/`** -- per-machine configurations.

## Directory structure

Files are grouped by domain. `import-tree` auto-discovers all `.nix` files
recursively, so directory placement is purely organizational -- it does not
affect module names or imports.

```
flake.nix
modules/
  flake-parts.nix                   # Bootstrap: systems, flakeModules
  nixosconfigurations.nix           # Host -> nixosSystem mapping
  roles/                            # Role composition (group modules)
    base.nix                        #   Minimal foundation
    networked.nix                   #   DNS + firewall
    headful.nix                     #   Graphical desktop
    multimedia.nix                  #   Audio + Bluetooth
    personal.nix                    #   Password manager, printing, theme
    portable.nix                    #   Laptop power/input
    development.nix                 #   Dev tools + groups
  hosts/                            # Per-machine configurations
    desknix/                        #   Desktop workstation
    thinkpad/                       #   Laptop
  users/                            # User definitions
    max.nix                         #   User "max" + home-manager wiring
  desktop/                          # Graphical desktop modules
    ags.nix                         #   Status bar (Aylur's GTK Shell)
    fonts.nix                       #   System font packages
    greeter.nix                     #   Display manager (regreet/greetd)
    gtk.nix                         #   GTK theme + icons
    hyprland.nix                    #   Hyprland compositor
    niri/                           #   Niri compositor + config
    playerctld.nix                  #   MPRIS player daemon
    polkit.nix                      #   Polkit authentication agent
    rofi.nix                        #   Application launcher
    screenlocker.nix                #   Screen lock (swayidle/swaylock)
    swww.nix                        #   Wallpaper daemon
    walker.nix                      #   Application launcher
    waybar.nix                      #   Status bar
    xdg.nix                         #   XDG portals + MIME
    wallpapers/                     #   Wallpaper images
  development/                      # Developer tooling modules
    codex.nix                       #   AI coding tools
    direnv.nix                      #   direnv + nix-direnv
    git.nix                         #   Git configuration
    kubectl.nix                     #   Kubernetes tools
    neovim.nix                      #   Neovim editor
    packages.nix                    #   Dev packages (large list)
    rstudio.nix                     #   RStudio
    vscode.nix                      #   VSCode
  hardware/                         # Hardware-specific modules
    bluetooth.nix                   #   Bluetooth + Blueman
    fingerprint.nix                 #   Fingerprint reader
    keyboards.nix                   #   QMK/Via udev rules
    nvidia.nix                      #   NVIDIA GPU drivers
    pipewire.nix                    #   PipeWire audio stack
    tlp.nix                         #   TLP power management
  networking/                       # Networking modules
    networkmanager.nix              #   NetworkManager
  services/                         # System service modules
    1password.nix                   #   1Password CLI + GUI
    cachix.nix                      #   Binary cache substituters
    clamav.nix                      #   ClamAV antivirus
    docker.nix                      #   Docker + KVM
    gaming.nix                      #   Steam + related
    printer.nix                     #   CUPS + Avahi printing
  system/                           # Core system configuration
    locale.nix                      #   Locale + timezone
    registry.nix                    #   Nix flake registry
    shell.nix                       #   Zsh shell
    ssh.nix                         #   SSH + GPG agent
    terminal.nix                    #   Terminal emulators
  nixpkgs/                          # Nixpkgs overlays + config
  packages/                         # Custom package definitions
```
