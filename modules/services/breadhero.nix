{
  nixos.services.breadhero =
    { my, ... }:
    let
      port = 3002;
    in
    {
      imports = [ my.modules.nixos.system.guests ];

      my.cachePackages.breadhero = my.pkgs.breadhero;

      my.guests.breadhero = {
        ip = 3;
        secrets = {
          slack-bot-token = my.secrets.breadhero-slack-bot-token.file;
          slack-signing-secret = my.secrets.breadhero-slack-signing-secret.file;
          leaderboard-api-key = my.secrets.breadhero-leaderboard-api-key.file;
        };
        proxy."breadhero.maxverbeek.dev" = port;
        modules = [
          my.modules.external.breadhero
          (
            { secrets, ... }:
            {
              services.breadhero = {
                enable = true;
                inherit port;
                slackBotTokenFile = secrets.slack-bot-token;
                slackSigningSecretFile = secrets.slack-signing-secret;
                leaderboardApiKeyFile = secrets.leaderboard-api-key;
              };
            }
          )
        ];
      };
    };
}
