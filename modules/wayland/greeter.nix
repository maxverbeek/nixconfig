{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = ../../wallpapers/windows.png;
        fit = "Cover";
      };

      GTK.application_prefer_dark_theme = true;

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
  };

  security.rtkit.enable = true;
  security.pam.services.swaylock = { };
}
