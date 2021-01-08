{
  imports = [ ./options.nix ];

  config.modules.picom = {
    enable = true;
    experimentalBackends = true;
  };
}
