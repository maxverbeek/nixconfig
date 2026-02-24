{
  lib,
  config,
  inputs,
  ...
}:
let
  sharedOverlays = [
    # gitlab-reviewer as overlay (the flake only exposes packages, not overlays)
    (final: prev: {
      gitlab-reviewer = inputs.gitlab-reviewer.packages.${prev.system}.default;
    })
  ];

  nixpkgsConfig = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "teams-1.5.00.23861" ];
    };

    overlays = [
      # custom packages + unstable + ruby-custom + flake outputs
      (final: prev: {
        custom = builtins.mapAttrs (n: d: final.callPackage d { }) (import ../packages/_custom);
        unstable = import inputs.unstable {
          inherit (prev) system;
          inherit (nixpkgsConfig) config;
          overlays = sharedOverlays;
        };
        ruby-custom = import inputs.nixpkgs-ruby {
          inherit (prev) system;
          inherit (nixpkgsConfig) config;
        };
        zen-browser = inputs.zen-browser.packages.${prev.system};
        agsmax = inputs.ags.packages.${prev.system}.default;
      })

      # packages from flakes
      (final: prev: {
        xtee = inputs.xtee.packages.${prev.system}.default;
        opencode = inputs.opencode.packages.${prev.system}.opencode;
      })

      # version overrides
      (import ../_overlays)
    ]
    ++ sharedOverlays;
  };
in
{
  config = {
    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          inherit (nixpkgsConfig) config overlays;
        };

        _module.args.unstable = import inputs.unstable {
          inherit system;
          inherit (nixpkgsConfig) config;
          overlays = sharedOverlays;
        };
      };

    # expose nixpkgsConfig so host definitions can use it
    flake.lib.nixpkgsConfig = nixpkgsConfig;
  };
}
