{
  nixos.services.feedbackers =
    { my, ... }:
    {
      imports = [ my.modules.nixos.system.guests ];

      my.cachePackages.feedbackers = my.pkgs.feedbackers;

      my.guests.feedbackers = {
        ip = 2;
        secrets.env = my.secrets.feedbackers-env.file;
        proxy."feedbackframework.maxverbeek.dev" = 3001;
        modules = [
          my.modules.external.feedbackers
          (
            { secrets, ... }:
            {
              services.feedbackers = {
                enable = true;
                environmentFile = secrets.env;
              };
            }
          )
        ];
      };
    };
}
