{
  # gog CLI.
  #
  # Tokens live in the OS keyring (Secret Service, from gnome-keyring in the
  # workstation collection) rather than gog's encrypted-file backend, so there is no
  # GOG_KEYRING_PASSWORD to store. Upstream's own advice: the file backend and
  # its password are for headless boxes only.
  nixos.programs.gog =
    { my, ... }:
    {
      environment.systemPackages = [ my.pkgs.gog ];

      environment.variables = {
        # `keychain` is the macOS backend and never resolves on Linux; `auto`
        # is what picks the Secret Service here. (`auto` would fall back to the
        # file backend if the Secret Service were missing, but the workstation collection
        # guarantees it: see services.gnome.gnome-keyring in modules/programs/greeter.nix.)
        GOG_KEYRING_BACKEND = "auto";

        # Default is a private `gogcli` collection, which PAM does not unlock,
        # so every session prompts for its password. The `login` collection is
        # the one greetd unlocks at login via enableGnomeKeyring.
        GOG_KEYRING_SERVICE_NAME = "login";
      };
    };
}
