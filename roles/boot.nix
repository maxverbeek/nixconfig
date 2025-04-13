{ config, lib, ... }:
let
  cfg = config.roles.boot;
in
{
  options = {
    enable = lib.mkEnableOption "Enable boot module";
    luksdevice = lib.mkOption {
      type = lib.type.string;
      description = "UUID of luks root device";
      optional = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices.root = lib.mkIf cfg.luksdevice {
      device = cfg.luksdevice;
      preLVM = true;
      allowDiscards = true;
    };
  };
}
