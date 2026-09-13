{
  inputs,
  config,
  my,
  ...
}:
{
  # Minimal NixOS module for user "max"
  # Provides user creation and the home-manager wiring.
  # Desktop hosts should add extra HM role imports (headful, personal, development) directly.
  flake.modules.nixos.max =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.max =
        { ... }:
        {

          home.stateVersion = "20.09";

          home.sessionVariables = {
            EDITOR = "nvim";
          };
        };

      users.users.max = {
        isNormalUser = true;
        # The path, not the package: NixOS's utils.toShellPath rewrites a shell
        # *package* to /run/current-system/sw/bin/zsh, which is the plain
        # pkgs.zsh that programs.zsh.enable puts in the system profile -- the
        # wrapper would never actually be the login shell. A path is passed
        # through unchanged.
        shell = "${my.pkgs.wrapped.zsh}/bin/zsh";
        extraGroups = [
          "wheel"
          "nordvpn"
        ];
      };
    };
}
