{
  nixos.programs.greeter =
    {
      my,
      pkgs,
      config,
      ...
    }:
    {
      programs.regreet = {
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

      services.greetd.enable = config.programs.regreet.enable;
      services.dbus.packages = [ pkgs.gcr ];
      # PAM's enableGnomeKeyring only runs the daemon as `--login`: it unlocks
      # the login keyring with the greetd password but serves nothing on the
      # bus. The secrets component is what actually backs
      # org.freedesktop.secrets, and any Secret Service consumer (gog, see
      # modules/development/gog.nix) fails with "keyring backend not
      # available" without it. This needs no unit of our own: the enable below
      # puts pkgs.gnome-keyring on services.dbus.packages, and the package's
      # own org.freedesktop.secrets.service activates
      # `gnome-keyring-daemon --start --foreground --components=secrets` on
      # first bus request. Was flake.modules.homeManager.headful's
      # services.gnome-keyring with components = [ "secrets" ].
      services.gnome.gnome-keyring.enable = true;

      security.pam.services.greetd.enableGnomeKeyring = true;
      security.rtkit.enable = true;
    };
}
