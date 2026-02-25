{ inputs, config, ... }:
let
  inputsoverlay = (
    final: prev:
    let
      system = prev.stdenv.hostPlatform.system;
    in
    {
      # add some packages from inputs into nixpkgs
      gitlab-reviewer = inputs.gitlab-reviewer.packages.${system}.default;
      zen-browser = inputs.zen-browser.packages.${system}.default;
      agsmax = inputs.ags.packages.${system}.default;
      xtee = inputs.xtee.packages.${system}.default;
    }
  );
in
{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.unstable {
        system = prev.stdenv.hostPlatform.system;
        inherit (config.nixpkgs) config;
        # additionally, make the packages from inputs available in unstable
        overlays = [ inputsoverlay ];
      };
    })

    # add it to normal nixpkgs as well
    inputsoverlay
  ];
}
