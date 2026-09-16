# Every secret once: the ciphertext and, when not just scopecreep, the `hosts`
# that decrypt it. max is always a recipient. secrets.nix derives the agenix manifest from this and
# modules reference `my.secrets.<name>.file`.
{
  breadhero-slack-bot-token.file = ./breadhero-slack-bot-token.age;
  breadhero-slack-signing-secret.file = ./breadhero-slack-signing-secret.age;
  breadhero-leaderboard-api-key.file = ./breadhero-leaderboard-api-key.age;
  feedbackers-env.file = ./feedbackers-env.age;
  huurhunter-env.file = ./huurhunter-env.age;
  huurhunter-monitor-env.file = ./huurhunter-monitor-env.age;
  webdav-htpasswd.file = ./webdav-htpasswd.age;
  harmonia-signing-key.file = ./harmonia-signing-key.age;
  # thinkpad decrypts with max's key (no sshd there), so it needs no host entry.
  nordlynx-key.file = ./nordlynx-key.age;
}
