{ ... }:
{
  flake.modules.nixos.bluetooth = {
    users.users.max.extraGroups = [ "bluetooth" ];

    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    services.blueman.enable = true;
    services.pipewire.wireplumber.enable = true;
  };
}
