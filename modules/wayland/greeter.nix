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

      GTK = {
        application_prefer_dark_theme = true;
        cursor_theme_name = "McMojave-cursors";
        # font_name = "Jost * 12";
        icon_theme_name = "Papirus-Dark";
        theme_name = "Catppuccin-Mocha-Compact-Mauve-Dark";
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
