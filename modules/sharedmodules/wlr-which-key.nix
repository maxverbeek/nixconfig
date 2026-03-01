{ ... }:
{
  flake.homeModules.wlr-which-key =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      inherit (lib)
        mkOption
        mkEnableOption
        mkIf
        types
        ;

      menuItemType = types.submodule {
        options = {
          key = mkOption {
            type = types.str;
            description = "Key binding for this menu entry.";
          };

          desc = mkOption {
            type = types.str;
            description = "Description shown in the menu.";
          };

          cmd = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Command to execute (leaf node).";
          };

          submenu = mkOption {
            type = types.nullOr (types.listOf menuItemType);
            default = null;
            description = "Nested submenu entries.";
          };
        };
      };

      anchorType = types.enum [
        "center"
        "left"
        "right"
        "top"
        "bottom"
        "top-left"
        "top-right"
        "bottom-left"
        "bottom-right"
      ];

    in
    {
      config = mkIf config.programs.wlr-which-key.enable {
        xdg.configFile."wlr-which-key/config.yaml".text = (
          lib.generators.toYAML { } config.programs.wlr-which-key.config
        );

        home.packages = [ pkgs.wlr-which-key ];
      };

      options.programs.wlr-which-key.enable = mkEnableOption "Enable wlr-which-key";
      options.programs.wlr-which-key.config = {
        menu = mkOption {
          type = types.listOf menuItemType;
          default = [ ];
          description = "Top-level menu entries.";
        };

        font = mkOption {
          type = types.str;
          default = "JetBrainsMono Nerd Font 12";
          description = "Font specification.";
        };

        background = mkOption {
          type = types.str;
          default = "#282828d0";
          description = "Background color (with optional alpha).";
        };

        color = mkOption {
          type = types.str;
          default = "#fbf1c7";
          description = "Foreground text color.";
        };

        border = mkOption {
          type = types.str;
          default = "#8ec07c";
          description = "Border color.";
        };

        separator = mkOption {
          type = types.str;
          default = " ➜ ";
          description = "Separator string between breadcrumb levels.";
        };

        border_width = mkOption {
          type = types.int;
          default = 2;
          description = "Border width in pixels.";
        };

        corner_r = mkOption {
          type = types.int;
          default = 10;
          description = "Corner radius in pixels.";
        };

        padding = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Padding in pixels. Defaults to corner_r if unset.";
        };

        rows_per_column = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Max rows per column. No limit by default.";
        };

        column_padding = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Column padding in pixels. Defaults to padding if unset.";
        };

        anchor = mkOption {
          type = anchorType;
          default = "center";
          description = "Screen anchor position.";
        };

        margin_right = mkOption {
          type = types.int;
          default = 0;
          description = "Right margin (only relevant when anchor is not center).";
        };

        margin_bottom = mkOption {
          type = types.int;
          default = 0;
          description = "Bottom margin (only relevant when anchor is not center).";
        };

        margin_left = mkOption {
          type = types.int;
          default = 0;
          description = "Left margin (only relevant when anchor is not center).";
        };

        margin_top = mkOption {
          type = types.int;
          default = 0;
          description = "Top margin (only relevant when anchor is not center).";
        };

        inhibit_compositor_keyboard_shortcuts = mkOption {
          type = types.bool;
          default = false;
          description = "Permit key bindings that conflict with compositor key bindings.";
        };

        auto_kbd_layout = mkOption {
          type = types.bool;
          default = false;
          description = "Try to guess the correct keyboard layout to use.";
        };
      };
    };
}
