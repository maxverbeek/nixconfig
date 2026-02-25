{ ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam.enable = true;

      environment.systemPackages = with pkgs; [
        alsa-ucm-conf
        steamcmd
        steam-tui
      ];
    };
}
