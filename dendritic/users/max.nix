{ inputs, config, ... }:
{
  # NixOS module for user "max"
  # This wires home-manager and composes all HM modules from the archetypes.
  flake.modules.nixos.max =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.max =
        { ... }:
        {
          imports = [
            # Device options (screens, battery, wifi, etc.)
            config.flake.modules.homeManager.deviceOptions

            # Base archetype HM modules
            config.flake.modules.homeManager.base
            config.flake.modules.homeManager.shell
            config.flake.modules.homeManager.terminal
            config.flake.modules.homeManager.gtk
            config.flake.modules.homeManager.ssh

            # Headful archetype HM modules
            config.flake.modules.homeManager.headful
            config.flake.modules.homeManager.niri
            config.flake.modules.homeManager.waybar
            config.flake.modules.homeManager.ags
            config.flake.modules.homeManager.polkit
            config.flake.modules.homeManager.playerctld
            config.flake.modules.homeManager.rofi
            config.flake.modules.homeManager.walker
            config.flake.modules.homeManager.hyprland
            config.flake.modules.homeManager.swww
            config.flake.modules.homeManager.i3
            config.flake.modules.homeManager.autorandr
            config.flake.modules.homeManager.screenlocker

            # Development archetype HM modules
            config.flake.modules.homeManager.development
            config.flake.modules.homeManager.git
            config.flake.modules.homeManager.codex
            config.flake.modules.homeManager.direnv
            config.flake.modules.homeManager.kubectl
            config.flake.modules.homeManager.vscode
            config.flake.modules.homeManager.rstudio
            config.flake.modules.homeManager.devpackages
            config.flake.modules.homeManager.neovim
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
