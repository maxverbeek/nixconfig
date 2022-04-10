{ pkgs, config, lib, ... }:
with lib; {
  options = { modules.direnv.enable = mkEnableOption "Enable direnv"; };

  config = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;

      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    };
  };
}
