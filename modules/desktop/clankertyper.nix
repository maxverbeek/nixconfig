{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      cachePackages.clankertyper = inputs.clankertyper.packages.${system}.default;
    };

  flake.modules.homeManager.headful =
    { pkgs, ... }:
    let
      package = inputs.clankertyper.packages.${pkgs.stdenv.hostPlatform.system}.default;
      toggle = pkgs.writeShellApplication {
        name = "clankertyper-toggle";
        runtimeInputs = [ pkgs.systemd ];
        text = ''
          if systemctl --user is-active --quiet clankertyper.service; then
            systemctl --user stop clankertyper.service
          else
            systemctl --user start clankertyper.service
          fi
        '';
      };
    in
    {
      home.packages = [
        package
        toggle
      ];

      systemd.user.services.clankertyper = {
        Unit = {
          Description = "Wayland voice dictation";
          After = [ "niri.service" ];
        };
        Service = {
          ExecStart = "${package}/bin/clankertyper";
          TimeoutStopSec = "2s";
        };
      };
    };
}
