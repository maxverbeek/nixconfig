{ ... }:
{
  flake.modules.nixos.greeter =
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

      environment.systemPackages = with pkgs; [
        glib
        custom.mcmojave-cursors
        (catppuccin-gtk.override {
          accents = [ "mauve" ];
          size = "compact";
          variant = "mocha";
        })
        bibata-cursors
        papirus-icon-theme
      ];

      services.greetd.enable = config.programs.regreet.enable;

      security.rtkit.enable = true;
      security.pam.services.swaylock = { };
    };
}
