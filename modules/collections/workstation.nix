{
  # A machine with a screen and a human: the compositor, its bar and launcher,
  # sound, bluetooth, fonts and the desktop programs. Today's headful +
  # personal + multimedia.
  nixos.collections.workstation =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        system.xdg
        system.fonts
        system.cachix
        hardware.bluetooth
        hardware.pipewire
        network.networkmanager
        network.mullvad
        network.nordvpn
        network.cloudflared
        programs.niri
        programs.greeter
        programs.theme
        programs.gtk
        programs.terminal
        programs.barbell
        programs.walker
        programs.rofi
        programs.wlr-which-key
        programs.awww
        programs.lock
        programs.polkit
        programs.playerctld
        programs.wayscriber
        programs.clankertyper
        programs.stalker
        programs.desktop-tools
        programs.office
        programs."1password"
        programs.pokemon-emerald
        services.printing
      ];
    };
}
