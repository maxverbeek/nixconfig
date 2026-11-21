{
  nixos.services.claude-remote =
    {
      my,
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = [
        # Over system.vps's plain git, so commits made here carry max's identity.
        (lib.hiPrio my.pkgs.wrapped.git)
        pkgs.gh
        pkgs.just
      ];

      # Lets `just switch` deploy from a checkout here. This makes wheel (and so
      # any claude session max runs) root-equivalent.
      security.sudo.wheelNeedsPassword = false;

      # Live symlink into the checkout at repoRoot; dangles until it is cloned.
      systemd.user.tmpfiles.users.max.rules = [
        "L+ %h/.claude/CLAUDE.md - - - - ${my.meta.repoRoot}/modules/services/claude-remote.md"
      ];

      # Sessions start in ~/projects; trust it once with an interactive `claude`
      # there, or spawned sessions stall on the trust prompt.
      systemd.user.services.claude-rc = {
        description = "Claude Remote Control";
        wantedBy = [ "default.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          WorkingDirectory = "%h/projects";
          ExecStart = "${my.pkgs.claude-code}/bin/claude remote-control --permission-mode bypassPermissions";
          Restart = "always";
          RestartSec = 30;
        };
      };
    };
}
