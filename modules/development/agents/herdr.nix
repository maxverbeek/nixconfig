{ config, ... }:
{
  # Reusable wrapper module in upstream shape (nix-wrapper-modules wrapperModules/h/herdr/module.nix).
  # Exported as outputs.modules.wrapper.herdr; consumers import it into their own flake.wrappers.herdr.
  flake.modules.wrapper.herdr =
    {
      config,
      lib,
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options.settings = lib.mkOption {
        type = wlib.types.structuredValueWith {
          nullable = false;
          typeName = "TOML";
        };
        default = { };
        description = ''
          Configuration of herdr's `config.toml`.
          Run `herdr --default-config` for the annotated defaults, or see <https://herdr.dev>.
        '';
        example = {
          theme.name = "kanagawa";
          terminal.default_shell = "zsh";
        };
      };

      config = {
        package = lib.mkDefault pkgs.herdr;

        # The generated config lives in the store, so herdr's own writes to it fail:
        # skip the first-run onboarding write and the self-updater (nix owns the binary).
        settings = {
          onboarding = lib.mkDefault false;
          update.version_check = lib.mkDefault false;
        };

        constructFiles."config.toml" = {
          content = builtins.toJSON config.settings;
          relPath = "${config.binName}-config.toml";
          builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
        };

        env.HERDR_CONFIG_PATH = config.constructFiles."config.toml".path;

        meta = {
          maintainers = [
            {
              name = "Max Verbeek";
              github = "maxverbeek";
              githubId = 8481950;
            }
          ];
          description = ''
            Wrapper module for [herdr](https://herdr.dev), the terminal agent multiplexer.

            The config file is generated from `settings` and passed via `HERDR_CONFIG_PATH`.
            Settings herdr changes at runtime (theme picker, `herdr channel set`, `herdr config
            reset-keys`) cannot be persisted from a wrapped install; set them in `settings` instead.
          '';
        };
      };
    };

  # My instance of it: becomes packages.<system>.herdr and pkgs.self.herdr.
  flake.wrappers.herdr =
    { pkgs, ... }:
    {
      imports = [ config.flake.modules.wrapper.herdr ];
      package = pkgs.unstable.herdr;
      settings.ui.agent_panel_sort = "spaces";
    };
}
