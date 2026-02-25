{ config, ... }:
{
  flake.modules.nixos.development = {
    imports = with config.flake.modules.nixos; [
      kvm
    ];

    users.users.max.extraGroups = [
      "plugdev"
      "dialout"
      "adbusers"
    ];
  };

  flake.modules.homeManager.development =
    { ... }:
    {
      imports = with config.flake.modules.homeManager; [
        agents
        dev-packages
        direnv
        git
        kubectl
        kvm
        neovim
        rstudio
        vscode
      ];
    };
}
