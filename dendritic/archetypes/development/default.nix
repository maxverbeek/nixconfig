{ config, ... }:
{
  flake.modules.nixos.development = { };

  flake.modules.homeManager.development =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        codex
        dev-packages
        direnv
        git
        kubectl
        neovim
        rstudio
        vscode
      ];
    };
}
