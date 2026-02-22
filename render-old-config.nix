# render-old-config.nix
#
# Renders the evaluated NixOS configuration from the old nixconfig repo
# into a JSON-serializable attribute set for migration comparison.
#
# This script manually constructs the NixOS evaluation from the old config's
# module tree, working around broken references in the old flake.nix.
#
# Usage:
#   nix eval --impure --json --expr 'import ./render-old-config.nix "thinkpad"' | jq -S . > old-thinkpad.json
#   nix eval --impure --json --expr 'import ./render-old-config.nix "desknix"'  | jq -S . > old-desknix.json
#
# Exclusions / workarounds (packages and options that cannot be evaluated cleanly):
#
#   Stubbed packages (appear in output as stub names, not real derivations):
#     - gitlab-reviewer    : overlay (gitlab-reviewer.overlays.default) missing in locked flake input
#     - docker-machine-kvm2: removed from nixpkgs
#     - neo4j-desktop      : removed from nixpkgs
#     - amazon-q-cli       : evaluation issues
#     - code-cursor        : broken callPackage in nixpkgs (vscode/generic.nix API mismatch)
#     - jetbrains.idea-community: removed from nixpkgs (discontinued by JetBrains)
#     - vscode             : API mismatch in vscode/generic.nix; fhsWithPackages stubbed
#     - custom.kiro        : passes `meta` to wrong curried function in vscode/generic.nix
#     - zen-browser, ags, xtee: flake output functions require all inputs; stubbed for simplicity
#
#   Disabled modules:
#     - home-manager.users.max.modules.vscode: triggers vscode/generic.nix API mismatch
#
#   Skipped services/programs in filterEnabled (use `abort` for renamed options, uncatchable):
#     - frp, immersed-vr, nekoray, redis, resolved, vmalert
#
#   Skipped option values:
#     - services.resolved.fallbackDns: renamed to settings.Resolve.FallbackDNS (abort)
#

host:

let
  oldFlakeLock = builtins.fromJSON (builtins.readFile ../nixconfig/flake.lock);
  oldRoot = ../nixconfig;

  # Resolve a flake input from the lockfile to a fetchable source
  resolveInput =
    name:
    let
      node = oldFlakeLock.nodes.${name};
      locked = node.locked;
    in
    if locked.type == "github" then
      builtins.fetchTarball {
        url = "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
        sha256 = locked.narHash;
      }
    else
      throw "Unsupported input type: ${locked.type} for input ${name}";

  nixpkgs = import (resolveInput "nixpkgs") { };
  lib = nixpkgs.lib;

  nixpkgsPath = resolveInput "nixpkgs";
  unstablePath = resolveInput "unstable";
  oldpkgsPath = resolveInput "oldpkgs";
  nixpkgsRubyPath = resolveInput "nixpkgs-ruby";
  homeMgrPath = resolveInput "home-manager";
  walkerPath = resolveInput "walker";
  xteePath = resolveInput "xtee";
  agsPath = resolveInput "ags";
  zenBrowserPath = resolveInput "zen-browser";
  elephantPath = resolveInput "elephant";

  # Stub package for mocking flake package outputs
  stubPkg = nixpkgs.runCommand "stub-pkg" { } "mkdir -p $out/bin";

  # Elephant HM module
  elephantSelf = {
    packages.x86_64-linux = {
      default = stubPkg;
      elephant-with-providers = stubPkg;
    };
    homeManagerModules = {
      default = elephantSelf.homeManagerModules.elephant;
      elephant = import "${elephantPath}/nix/modules/home-manager.nix" elephantSelf;
    };
  };

  # Walker HM module
  walkerSelf = {
    packages.x86_64-linux = {
      default = stubPkg;
      walker = stubPkg;
    };
  };
  walkerHmModule = import "${walkerPath}/nix/modules/home-manager.nix" {
    self = walkerSelf;
    elephant = elephantSelf;
  };

  # Shared overlays (minus broken gitlab-reviewer.overlays.default)
  sharedOverlays = [
    (import "${oldRoot}/neovim")
  ];

  nixpkgsConfig = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "teams-1.5.00.23861" ];
    };

    overlays = [
      # Stub overlay: packages broken due to API changes or missing flake overlays.
      # Must come FIRST so that the custom overlay below can reference these stubs if needed.
      (
        final: prev:
        let
          stub = name: prev.runCommand name { } "mkdir -p $out/bin";
        in
        {
          docker-machine-kvm2 = stub "docker-machine-kvm2";
          gitlab-reviewer = stub "gitlab-reviewer";
          neo4j-desktop = stub "neo4j-desktop";
          amazon-q-cli = stub "amazon-q-cli";
          code-cursor = stub "code-cursor";
          jetbrains = prev.jetbrains // {
            idea-community = stub "idea-community";
          };
          vscode = (stub "vscode") // {
            fhsWithPackages = _: stub "vscode-fhs";
          };
        }
      )
      (final: prev: {
        custom =
          let
            stub = name: prev.runCommand name { } "mkdir -p $out/bin";
            pkgDefs = import "${oldRoot}/packages";
            # Some custom packages have callPackage bugs (kiro passes meta to wrong function)
            brokenPkgs = {
              kiro = stub "kiro";
            };
          in
          builtins.mapAttrs (n: d: final.callPackage d { }) (
            lib.filterAttrs (n: _: !brokenPkgs ? ${n}) pkgDefs
          )
          // brokenPkgs;
        unstable = import unstablePath {
          inherit (prev) system;
          config = nixpkgsConfig.config;
          overlays = sharedOverlays;
        };
        oldpkgs = import oldpkgsPath {
          inherit (prev) system;
          config = nixpkgsConfig.config;
        };
        ruby-custom = import nixpkgsRubyPath {
          inherit (prev) system;
          config = nixpkgsConfig.config;
        };
        # These flake packages have complex output functions requiring all inputs.
        # Stub them since we only need names, not working derivations.
        zen-browser = {
          default = prev.runCommand "zen-browser" { } "mkdir -p $out/bin";
        };
        agsmax = prev.runCommand "agsmax" { } "mkdir -p $out/bin";
        xtee = prev.runCommand "xtee" { } "mkdir -p $out/bin";
      })

      (import "${oldRoot}/overlays")
    ]
    ++ sharedOverlays;
  };

  # Host-specific settings
  hostArgs =
    {
      thinkpad = {
        nvidia = false;
        configPath = "${oldRoot}/hosts/thinkpad/configuration.nix";
        devicePath = "${oldRoot}/hosts/thinkpad/device.nix";
      };
      desknix = {
        nvidia = true;
        configPath = "${oldRoot}/hosts/desknix/configuration.nix";
        devicePath = "${oldRoot}/hosts/desknix/device.nix";
      };
      lenovo-laptop = {
        nvidia = false;
        configPath = "${oldRoot}/hosts/lenovo-laptop/configuration.nix";
        devicePath = "${oldRoot}/hosts/lenovo-laptop/device.nix";
      };
    }
    .${host} or (throw "Unknown host: ${host}. Expected one of: thinkpad, desknix, lenovo-laptop");

  # Evaluate the NixOS configuration
  eval = import "${nixpkgsPath}/nixos/lib/eval-config.nix" {
    system = "x86_64-linux";
    specialArgs = {
      inherit (hostArgs) nvidia;
    };
    modules = [
      { nixpkgs = nixpkgsConfig; }

      # cachix
      {
        nix.settings = {
          substituters = [ "https://hyprland.cachix.org" ];
          trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
          extra-substituters = [
            "https://walker.cachix.org"
            "https://walker-git.cachix.org"
          ];
          extra-trusted-public-keys = [
            "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
            "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
          ];
        };
      }

      # home-manager module
      (import "${homeMgrPath}/nixos")

      # home-manager settings
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.max.imports = [
          "${oldRoot}/home/max.nix"
          "${oldRoot}/hosts/options.nix"
          walkerHmModule
          hostArgs.devicePath
        ];
      }

      # Disable modules / packages that fail to evaluate due to nixpkgs API drift
      { home-manager.users.max.modules.vscode.enable = lib.mkForce false; }

      # Stub overlay applied as a separate module so it gets merged AFTER nixpkgsConfig.overlays.
      # In modern nixpkgs, by-name auto-call runs after user overlays, so we need this to override.
      {
        nixpkgs.overlays = lib.mkAfter [
          (
            final: prev:
            let
              stub = name: prev.runCommand name { } "mkdir -p $out/bin";
            in
            {
              code-cursor = stub "code-cursor";
              neo4j-desktop = stub "neo4j-desktop";
              amazon-q-cli = stub "amazon-q-cli";
              jetbrains = prev.jetbrains // {
                idea-community = stub "idea-community";
              };
              vscode = (stub "vscode") // {
                fhsWithPackages = _: stub "vscode-fhs";
              };
            }
          )
        ];
      }

      # host-specific NixOS configuration
      hostArgs.configPath
    ];
  };

  cfg = eval.config;
  hmCfg = cfg.home-manager.users.max;

  # ── Helpers ──

  # Convert a list of derivations to a sorted list of name strings.
  drvsToNames =
    drvs:
    let
      names = builtins.filter builtins.isString (
        map (
          p:
          let
            result = builtins.tryEval (p.pname or p.name or (builtins.toString p));
          in
          if result.success then result.value else null
        ) drvs
      );
    in
    builtins.sort builtins.lessThan names;

  # Options that use `abort` for renamed options — tryEval cannot catch abort.
  skipNames = [
    "frp"
    "immersed-vr"
    "nekoray"
    "redis"
    "resolved"
    "vmalert"
  ];

  # From an attrset where values may have `.enable`, return { name = true; } for each enabled one.
  filterEnabled =
    attrs:
    builtins.listToAttrs (
      builtins.concatMap (
        name:
        if builtins.elem name skipNames then
          [ ]
        else
          let
            r = builtins.tryEval (builtins.isAttrs attrs.${name} && (attrs.${name}.enable or false));
          in
          if r.success && r.value then
            [
              {
                inherit name;
                value = true;
              }
            ]
          else
            [ ]
      ) (builtins.attrNames attrs)
    );

  # Safely access a nested attribute
  safeGet =
    set: path: default:
    let
      go =
        s: p:
        if p == [ ] then
          s
        else if builtins.isAttrs s && builtins.hasAttr (builtins.head p) s then
          go s.${builtins.head p} (builtins.tail p)
        else
          default;
      result = builtins.tryEval (go set path);
    in
    if result.success then result.value else default;

  # Safely evaluate a value, returning default on throw
  safeEval =
    default: expr:
    let
      r = builtins.tryEval expr;
    in
    if r.success then r.value else default;

in
{
  system.stateVersion = cfg.system.stateVersion;

  boot = {
    loader = {
      systemd-boot.enable = safeGet cfg [ "boot" "loader" "systemd-boot" "enable" ] false;
      grub.enable = safeGet cfg [ "boot" "loader" "grub" "enable" ] false;
      efi.canTouchEfiVariables = safeGet cfg [ "boot" "loader" "efi" "canTouchEfiVariables" ] false;
    };
    kernelParams = safeEval [ ] cfg.boot.kernelParams;
    supportedFilesystems = safeEval { } (builtins.mapAttrs (_: _v: true) cfg.boot.supportedFilesystems);
    initrd.kernelModules = safeEval [ ] cfg.boot.initrd.kernelModules;
  };

  networking = {
    hostName = cfg.networking.hostName;
    firewall = {
      enable = cfg.networking.firewall.enable;
      allowedTCPPorts = safeEval [ ] cfg.networking.firewall.allowedTCPPorts;
      allowedUDPPorts = safeEval [ ] cfg.networking.firewall.allowedUDPPorts;
    };
    networkmanager.enable = safeGet cfg [ "networking" "networkmanager" "enable" ] false;
    nameservers = safeEval [ ] cfg.networking.nameservers;
    extraHosts = safeEval "" cfg.networking.extraHosts;
  };

  time.timeZone = cfg.time.timeZone;
  i18n.defaultLocale = cfg.i18n.defaultLocale;

  services = filterEnabled cfg.services;

  serviceDetails = {
    tailscale = {
      enable = safeGet cfg [ "services" "tailscale" "enable" ] false;
      useRoutingFeatures = safeGet cfg [ "services" "tailscale" "useRoutingFeatures" ] null;
    };
    pipewire = {
      enable = safeGet cfg [ "services" "pipewire" "enable" ] false;
      audio.enable = safeGet cfg [ "services" "pipewire" "audio" "enable" ] false;
      alsa.enable = safeGet cfg [ "services" "pipewire" "alsa" "enable" ] false;
    };
    tlp.enable = safeGet cfg [ "services" "tlp" "enable" ] false;
    resolved = {
      enable = safeGet cfg [ "services" "resolved" "enable" ] false;
      # fallbackDns was renamed to settings.Resolve.FallbackDNS and uses abort (uncatchable)
    };
    xserver = {
      enable = safeGet cfg [ "services" "xserver" "enable" ] false;
      videoDrivers = safeGet cfg [ "services" "xserver" "videoDrivers" ] [ ];
    };
  };

  programs = filterEnabled cfg.programs;

  virtualisation = {
    docker.enable = safeGet cfg [ "virtualisation" "docker" "enable" ] false;
    libvirtd.enable = safeGet cfg [ "virtualisation" "libvirtd" "enable" ] false;
  };

  hardware = {
    graphics.enable = safeGet cfg [ "hardware" "graphics" "enable" ] false;
    enableAllFirmware = safeGet cfg [ "hardware" "enableAllFirmware" ] false;
    enableRedistributableFirmware = safeGet cfg [ "hardware" "enableRedistributableFirmware" ] false;
    bluetooth.enable = safeGet cfg [ "hardware" "bluetooth" "enable" ] false;
    cpu.intel.updateMicrocode = safeGet cfg [ "hardware" "cpu" "intel" "updateMicrocode" ] false;
  };

  nix.settings = {
    experimental-features = safeGet cfg [ "nix" "settings" "experimental-features" ] [ ];
    substituters = safeGet cfg [ "nix" "settings" "substituters" ] [ ];
    trusted-public-keys = safeGet cfg [ "nix" "settings" "trusted-public-keys" ] [ ];
    extra-substituters = safeGet cfg [ "nix" "settings" "extra-substituters" ] [ ];
    extra-trusted-public-keys = safeGet cfg [ "nix" "settings" "extra-trusted-public-keys" ] [ ];
  };

  users.users.max = {
    isNormalUser = cfg.users.users.max.isNormalUser;
    extraGroups = safeEval [ ] cfg.users.users.max.extraGroups;
  };

  environment.systemPackages = safeEval [ "<eval-failed>" ] (
    drvsToNames cfg.environment.systemPackages
  );
  fonts.packages = safeEval [ "<eval-failed>" ] (drvsToNames cfg.fonts.packages);

  customModules = {
    kvm2.enable = safeGet cfg [ "modules" "kvm2" "enable" ] false;
    fingerprint.enable = safeGet cfg [ "modules" "fingerprint" "enable" ] false;
    niri.enable = safeGet cfg [ "modules" "niri" "enable" ] false;
    xwayland-satellite.enable = safeGet cfg [ "modules" "xwayland-satellite" "enable" ] false;
  };

  # ── Home-Manager ──

  home-manager = {
    stateVersion = hmCfg.home.stateVersion;
    packages = safeEval [ "<eval-failed>" ] (drvsToNames hmCfg.home.packages);
    programs = filterEnabled hmCfg.programs;
    services = filterEnabled hmCfg.services;

    customModules = {
      i3.enable = safeGet hmCfg [ "modules" "i3" "enable" ] false;
      git.enable = safeGet hmCfg [ "modules" "git" "enable" ] false;
      vscode.enable = safeGet hmCfg [ "modules" "vscode" "enable" ] false;
      kubectl.enable = safeGet hmCfg [ "modules" "kubectl" "enable" ] false;
      autorandr.enable = safeGet hmCfg [ "modules" "autorandr" "enable" ] false;
      polybar.enable = safeGet hmCfg [ "modules" "polybar" "enable" ] false;
      rofi.enable = safeGet hmCfg [ "modules" "rofi" "enable" ] false;
      fuzzel.enable = safeGet hmCfg [ "modules" "fuzzel" "enable" ] false;
      rstudio.enable = safeGet hmCfg [ "modules" "rstudio" "enable" ] false;
      screenlocker.enable = safeGet hmCfg [ "modules" "screenlocker" "enable" ] false;
      zsh.enable = safeGet hmCfg [ "modules" "zsh" "enable" ] false;
      alacritty.enable = safeGet hmCfg [ "modules" "alacritty" "enable" ] false;
      direnv.enable = safeGet hmCfg [ "modules" "direnv" "enable" ] false;
      playerctld.enable = safeGet hmCfg [ "modules" "playerctld" "enable" ] false;
      codex.enable = safeGet hmCfg [ "modules" "codex" "enable" ] false;
      walker.enable = safeGet hmCfg [ "modules" "walker" "enable" ] false;
      polkit.enable = safeGet hmCfg [ "modules" "polkit" "enable" ] false;
      hyprland.enable = safeGet hmCfg [ "modules" "hyprland" "enable" ] false;
      waybar.enable = safeGet hmCfg [ "modules" "waybar" "enable" ] false;
      picom.enable = safeGet hmCfg [ "modules" "picom" "enable" ] false;
    };

    device = {
      screens = safeGet hmCfg [ "device" "screens" ] [ ];
      hyprland.enable = safeGet hmCfg [ "device" "hyprland" "enable" ] false;
      wifi = {
        enabled = safeGet hmCfg [ "device" "wifi" "enabled" ] false;
        interface = safeGet hmCfg [ "device" "wifi" "interface" ] "";
      };
      hasBattery = safeGet hmCfg [ "device" "hasBattery" ] false;
      hasBrightness = safeGet hmCfg [ "device" "hasBrightness" ] false;
      withScreenLocker = safeGet hmCfg [ "device" "withScreenLocker" ] false;
      termFontSize = safeGet hmCfg [ "device" "termFontSize" ] 11;
    };

    sessionVariables = safeEval { } hmCfg.home.sessionVariables;

    gtk = {
      enable = safeEval false hmCfg.gtk.enable;
      iconTheme.name = safeGet hmCfg [ "gtk" "iconTheme" "name" ] null;
    };

    fonts.fontconfig.enable = safeGet hmCfg [ "fonts" "fontconfig" "enable" ] false;
  };
}
