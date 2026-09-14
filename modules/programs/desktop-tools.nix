{
  nixos.programs.desktop-tools =
    { pkgs, ... }:
    {
      services.gvfs.enable = true;

      environment.systemPackages = with pkgs; [
        fd
        brightnessctl
        swappy
        wayshot
        wl-clipboard
      ];
    };
}
