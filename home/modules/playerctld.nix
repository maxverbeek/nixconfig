{ lib, config, ... }:
with lib; {
  options = {
    modules.playerctld.enable = mkEnableOption "Enable playerctl integration";
  };

  config = mkIf config.modules.playerctld.enable {
    services.playerctld.enable = true;
  };
}
