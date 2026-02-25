{
  nixpkgs.overlays = [
    (final: prev: {

      # FIXME: wait for upstream fix
      slack = prev.slack.overrideAttrs (old: {
        installPhase = old.installPhase + ''
          # Patch the desktop entry to add Wayland flag
          substituteInPlace $out/share/applications/slack.desktop \
            --replace 'bin/slack -s' 'bin/slack -s --ozone-platform=wayland'
        '';
      });
    })
  ];
}
