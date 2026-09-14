{ ... }:
{
  flake.modules.nixos.headful =
    { pkgs, config, ... }:
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
            path = ./wallpapers/windows.png;
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

          commands = {
            reboot = [ "reboot" ];
            poweroff = [
              "shutdown"
              "now"
            ];
          };
        };
      };

      environment.systemPackages = with pkgs; [
        glib
        custom.mcmojave-cursors
        bibata-cursors
        papirus-icon-theme
      ];

      services.greetd.enable = config.programs.regreet.enable;
      services.dbus.packages = [ pkgs.gcr ];
      services.gnome.gnome-keyring.enable = true;

      security.pam.services.greetd.enableGnomeKeyring = true;
      security.rtkit.enable = true;
    };

  # PAM's enableGnomeKeyring only runs the daemon as `--login`: it unlocks the
  # login keyring with the greetd password but serves nothing on the bus. The
  # secrets component is what actually backs org.freedesktop.secrets, so
  # without this any Secret Service consumer (gog, see modules/development/gog.nix)
  # fails with "keyring backend not available".
  flake.modules.homeManager.headful = {
    services.gnome-keyring = {
      enable = true;
      components = [ "secrets" ];
    };
  };
}
