{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      cachePackages.clankertyper = inputs.clankertyper.packages.${system}.default;
    };

  flake.modules.nixos.headful =
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
      environment.systemPackages = [
        package
        toggle
      ];

      # No wantedBy: the unit is started on demand by clankertyper-toggle.
      systemd.user.services.clankertyper = {
        description = "Wayland voice dictation";
        after = [ "niri.service" ];
        serviceConfig = {
          ExecStart = "${package}/bin/clankertyper";
          TimeoutStopSec = "2s";
        };
      };
    };
}
