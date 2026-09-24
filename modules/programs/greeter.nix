{
  nixos.programs.greeter =
    {
      my,
      pkgs,
      ...
    }:
    {
      services.displayManager.regreet = {
        enable = true;
        cageArgs = [
          "-s"
          "-m"
          "last"
        ];
        settings = {
          background = {
            path = ../desktop/wallpapers/windows.png;
            fit = "Cover";
          };

          GTK.application_prefer_dark_theme = true;

          cursorTheme = {
            name = "McMojave-cursors";
            package = my.pkgs.mcmojave-cursors;
          };

          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
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

      environment.systemPackages = [
        pkgs.glib
        my.pkgs.mcmojave-cursors
        pkgs.bibata-cursors
        pkgs.papirus-icon-theme
      ];

      services.dbus.packages = [ pkgs.gcr_4 ];
      # PAM's enableGnomeKeyring only runs the daemon as `--login`: it unlocks
      # the login keyring but serves nothing on the bus, so Secret Service
      # consumers fail with "keyring backend not available". This enable is
      # enough: the package's own org.freedesktop.secrets.service starts the
      # secrets component on first bus request, no unit of ours needed.
      services.gnome.gnome-keyring.enable = true;

      security.pam.services.greetd.enableGnomeKeyring = true;
      security.rtkit.enable = true;
    };
}
