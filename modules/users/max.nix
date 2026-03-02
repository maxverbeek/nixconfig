{ inputs, config, ... }:
{
  # Minimal NixOS module for user "max"
  # Provides user creation, home-manager wiring, and the base HM role (zsh, starship, fzf, ssh).
  # Desktop hosts should add extra HM role imports (headful, personal, development) directly.
  flake.modules.nixos.max =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        config.flake.modules.nixos.shell
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.max =
        { ... }:
        {
          imports = with config.flake.modules.homeManager; [
            base
          ];

          home.stateVersion = "20.09";

          home.sessionVariables = {
            EDITOR = "nvim";
          };
        };

      users.users.max = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
        ];
      };
    };
}
