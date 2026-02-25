{ inputs, config, ... }:
{
  # NixOS module for user "max"
  # This wires home-manager and composes HM archetype modules.
  flake.modules.nixos.max =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.max =
        { ... }:
        {
          imports = with config.flake.modules.homeManager; [
            base
            headful
            development
          ];

          home.stateVersion = "20.09";

          home.sessionVariables = {
            JAVA_HOME = "${pkgs.openjdk17}/lib/openjdk";
            _JAVA_AWT_WM_NONREPARENTING = "1";
            EDITOR = "nvim";
          };
        };

      users.users.max = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "plugdev"
          "dialout"
          "input"
          "video"
          "audio"
          "adbusers"
        ];
      };
    };
}
