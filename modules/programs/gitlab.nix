{
  # One gitlab.com PAT, held in the Secret Service (`service=gitlab
  # host=gitlab.com`) and rotated every other day with a 20-day lifetime, so a
  # token that leaks (a transcript, a paste) is dead within two days.
  #
  # Bootstrap once, then delete the token line from glab's config.yml:
  #   tr -d '\n' < ~/.gitlab_pat \
  #     | secret-tool store --label='GitLab PAT (gitlab.com)' service gitlab host gitlab.com
  nixos.programs.gitlab =
    { my, pkgs, ... }:
    let
      lookup = "${pkgs.libsecret}/bin/secret-tool lookup service gitlab host gitlab.com";

      # An explicit GITLAB_TOKEN (CI, another account) still wins.
      glab = pkgs.symlinkJoin {
        name = "glab";
        paths = [ pkgs.glab ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/glab --run 'export GITLAB_TOKEN="''${GITLAB_TOKEN:-$(${lookup})}"'
        '';
      };

      gitlabcivars = pkgs.writeShellScriptBin "gitlabcivars" ''
        ${glab}/bin/glab variable export | ${pkgs.jq}/bin/jq -r '.[] | (.key + "=" + .value)'
      '';

      rotate = pkgs.writeShellApplication {
        name = "gitlab-token-rotate";
        runtimeInputs = [
          glab
          pkgs.jq
          pkgs.libsecret
          pkgs.coreutils
          pkgs.systemd
        ];
        text = ''
          umask 077
          # GitLab revokes the old token the moment this call succeeds, so the
          # response is written to tmpfs before anything else can fail. A
          # failed run leaves it here: store the token by hand from this file.
          response="$XDG_RUNTIME_DIR/gitlab-token-rotate.json"

          # self/rotate rotates whichever token authenticates the call: no
          # name or id to track, and both change on every rotation anyway.
          glab api --method POST personal_access_tokens/self/rotate \
            -f expires_at="$(date -d '+20 days' +%F)" > "$response"
          token=$(jq -er .token "$response")

          printf %s "$token" \
            | secret-tool store --label='GitLab PAT (gitlab.com)' service gitlab host gitlab.com

          # ponytail: plaintext mirror for stalker, gitlab-reviewer and
          # elephant-gitlab, which only read ~/.gitlab_pat; drop it once they
          # look the token up in the keyring.
          printf %s "$token" > "$HOME/.gitlab_pat.new"
          mv "$HOME/.gitlab_pat.new" "$HOME/.gitlab_pat"

          rm "$response"

          # Both read the token once at startup.
          systemctl --user try-restart stalker.service elephant.service
        '';
      };

      notifyFailure = pkgs.writeShellScript "gitlab-token-rotate-notify" ''
        [ "$SERVICE_RESULT" = success ] && exit 0
        ${pkgs.libnotify}/bin/notify-send -u critical "GitLab token rotation failed" \
          "journalctl --user -u gitlab-token-rotate"
      '';
    in
    {
      my.cachePackages.gitlab-reviewer = my.pkgs.gitlab-reviewer;

      environment.systemPackages = [
        glab
        gitlabcivars
        rotate
        my.pkgs.gitlab-reviewer
      ];

      systemd.user.services.gitlab-token-rotate = {
        description = "Rotate the gitlab.com personal access token";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${rotate}/bin/gitlab-token-rotate";
          ExecStopPost = "${notifyFailure}";
          # No Restart=: a retry after the rotate call went through would
          # authenticate with the revoked token, which GitLab treats as reuse
          # and answers by revoking the whole token family.
        };
      };

      # Bound to the graphical session so it only runs once PAM has unlocked
      # the keyring; Persistent catches up on a missed day at the next login.
      systemd.user.timers.gitlab-token-rotate = {
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        timerConfig = {
          OnCalendar = "*-*-1/2 10:00";
          Persistent = true;
        };
      };
    };
}
