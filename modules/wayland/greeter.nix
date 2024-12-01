{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.regreet = {
    enable = true;
    package = pkgs.unstable.greetd.regreet; # .overrideAttrs (old: { patches = [ ../patches/regreet-debug.patch ]; });
    settings = {
      background = {
        path = ../../wallpapers/windows.png;
        fit = "Cover";
      };

      cursorTheme = {
        name = "McMojave-cursors";
        package = pkgs.custom.mcmojave-cursors;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "Catppuccin-Mocha-Compact-Mauve-Dark";
        package = (
          pkgs.catppuccin-gtk.override {
            accents = [ "mauve" ];
            size = "compact";
            variant = "mocha";
          }
        );
      };

      commands = {
        reboot = [ "reboot" ];
        poweroff = [
          "shutdown"
          "now"
        ];
      };
    };
  };

  # themes for regreet
  environment.systemPackages = with pkgs; [
    glib
    custom.mcmojave-cursors
    # theme packages
    (catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "compact";
      variant = "mocha";
    })
    bibata-cursors
    papirus-icon-theme
  ];

  services.greetd = {
    # Configuration for using with regreet -- only enable if regreet is enabled
    enable = config.programs.regreet.enable;
    settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} -s -m last -- ${lib.getExe config.programs.regreet.package} -l debug";
  };

  security.rtkit.enable = true;
  security.pam.services.swaylock = { };
}
