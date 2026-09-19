{
  nixos.programs.clankertyper =
    { my, pkgs, ... }:
    let
      package = my.pkgs.clankertyper;
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
      my.cachePackages.clankertyper = package;

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
