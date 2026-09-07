# agenix recipient manifest. Only read by the `agenix` CLI (edit/rekey time),
# never by the flake. Run agenix from the repo root: `agenix -e secrets/<file>.age`.
let
  keys = import ./publickeys.nix;
  scopecreep = [
    keys.max
    keys.scopecreep
  ];
in
{
  "secrets/breadhero-slack-bot-token.age".publicKeys = scopecreep;
  "secrets/breadhero-slack-signing-secret.age".publicKeys = scopecreep;
  "secrets/breadhero-leaderboard-api-key.age".publicKeys = scopecreep;
  "secrets/feedbackers.env.age".publicKeys = scopecreep;
  "secrets/huurhunter.env.age".publicKeys = scopecreep;
  "secrets/huurhunter-monitor.env.age".publicKeys = scopecreep;
  "secrets/huurhunter-nordlynx.key.age".publicKeys = scopecreep;
  "secrets/webdav.htpasswd.age".publicKeys = scopecreep;
  "secrets/harmonia-signing-key.age".publicKeys = scopecreep;
  # thinkpad has no sshd host key; it decrypts with max's own key (age.identityPaths)
  "secrets/nordlynx.env.age".publicKeys = [ keys.max ];
}
