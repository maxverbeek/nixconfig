{
  flake.modules.homeManager.headful =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.unstable.wayscriber ];

      # Kanagawa-themed wayscriber config (immutable via xdg.configFile)
      xdg.configFile."wayscriber/config.toml".text =
        let
          kanagawa = pkgs.custom.kanagawa-nvim.colors.term;

          # Hex "#RRGGBB" -> { r, g, b } in 0-255
          hexToRgb =
            hex:
            let
              h = builtins.substring 1 6 hex; # strip leading #
              hexDigit =
                c:
                let
                  digits = {
                    "0" = 0;
                    "1" = 1;
                    "2" = 2;
                    "3" = 3;
                    "4" = 4;
                    "5" = 5;
                    "6" = 6;
                    "7" = 7;
                    "8" = 8;
                    "9" = 9;
                    "a" = 10;
                    "b" = 11;
                    "c" = 12;
                    "d" = 13;
                    "e" = 14;
                    "f" = 15;
                    "A" = 10;
                    "B" = 11;
                    "C" = 12;
                    "D" = 13;
                    "E" = 14;
                    "F" = 15;
                  };
                in
                digits.${c};
              byte =
                hi: lo:
                (hexDigit hi) * 16 + (hexDigit lo);
            in
            {
              r = byte (builtins.substring 0 1 h) (builtins.substring 1 1 h);
              g = byte (builtins.substring 2 1 h) (builtins.substring 3 1 h);
              b = byte (builtins.substring 4 1 h) (builtins.substring 5 1 h);
            };

          # Format as TOML integer array [R, G, B]
          rgbInt =
            hex:
            let
              c = hexToRgb hex;
            in
            "[${toString c.r}, ${toString c.g}, ${toString c.b}]";

          # Format as TOML float array [R, G, B, A] (0.0-1.0)
          rgbFloat =
            hex: alpha:
            let
              c = hexToRgb hex;
              # Nix doesn't have float division, so we use string formatting
              # We pre-compute to 3 decimal places
              fmtF = n: let i = n * 1000 / 255; in "${toString (i / 1000)}.${toString (i - (i / 1000) * 1000)}";
            in
            "[${fmtF c.r}, ${fmtF c.g}, ${fmtF c.b}, ${alpha}]";

          # Format as TOML float array [R, G, B] (0.0-1.0) without alpha
          rgbFloat3 =
            hex:
            let
              c = hexToRgb hex;
              fmtF = n: let i = n * 1000 / 255; in "${toString (i / 1000)}.${toString (i - (i / 1000) * 1000)}";
            in
            "[${fmtF c.r}, ${fmtF c.g}, ${fmtF c.b}]";

          red = kanagawa.normal.red;
          green = kanagawa.normal.green;
          blue = kanagawa.normal.blue;
          yellow = kanagawa.normal.yellow;
          fg = kanagawa.bright.white;
          bg = kanagawa.extended.background;
        in
        # All color values use kanagawa theme
        ''
          [drawing]
          default_color = ${rgbInt blue}
          default_thickness = 12.0
          default_eraser_size = 12.0
          default_eraser_mode = "stroke"
          marker_opacity = 0.9
          default_fill_enabled = false
          default_font_size = 32.0
          hit_test_tolerance = 6.0
          hit_test_linear_threshold = 400
          undo_stack_limit = 100
          font_family = "Monospace"
          font_weight = "normal"
          font_style = "normal"
          text_background_enabled = false

          [presets]
          slot_count = 5

          [presets.slot_1]
          tool = "pen"
          color = ${rgbInt blue}
          size = 12.0

          [presets.slot_2]
          tool = "pen"
          color = ${rgbInt red}
          size = 12.0

          [presets.slot_3]
          tool = "pen"
          color = ${rgbInt green}
          size = 12.0

          [presets.slot_4]
          tool = "pen"
          color = ${rgbInt yellow}
          size = 12.0

          [presets.slot_5]
          tool = "pen"
          color = ${rgbInt fg}
          size = 12.0

          [history]
          undo_all_delay_ms = 1000
          redo_all_delay_ms = 1000
          custom_section_enabled = false
          custom_undo_delay_ms = 1000
          custom_redo_delay_ms = 1000
          custom_undo_steps = 5
          custom_redo_steps = 5

          [arrow]
          length = 20.0
          angle_degrees = 30.0
          head_at_end = true

          [performance]
          buffer_count = 3
          enable_vsync = true
          max_fps_no_vsync = 60
          ui_animation_fps = 30

          [ui]
          show_status_bar = true
          show_status_board_badge = true
          show_status_page_badge = true
          show_floating_badge_always = false
          show_frozen_badge = false
          status_bar_position = "bottom-left"
          help_overlay_context_filter = true
          command_palette_toast_duration_ms = 1500
          xdg_fullscreen = false

          [ui.status_bar_style]
          font_size = 21.0
          padding = 15.0
          bg_color = ${rgbFloat bg "0.85"}
          text_color = ${rgbFloat fg "1.0"}
          dot_radius = 6.0

          [ui.help_overlay_style]
          font_size = 14.0
          font_family = "Noto Sans, DejaVu Sans, Liberation Sans, Sans"
          line_height = 22.0
          padding = 32.0
          bg_color = ${rgbFloat bg "0.92"}
          border_color = ${rgbFloat blue "0.88"}
          border_width = 2.0
          text_color = ${rgbFloat fg "1.0"}

          [ui.click_highlight]
          enabled = false
          show_on_highlight_tool = false
          radius = 24.0
          outline_thickness = 4.0
          duration_ms = 750
          fill_color = ${rgbFloat yellow "0.35"}
          outline_color = ${rgbFloat yellow "0.9"}
          use_pen_color = true

          [ui.context_menu]
          enabled = true

          [ui.toolbar]
          layout_mode = "simple"
          top_pinned = false
          side_pinned = false
          use_icons = false
          scale = 1.0
          show_more_colors = false
          show_actions_section = true
          show_actions_advanced = false
          show_zoom_actions = true
          show_pages_section = true
          show_boards_section = true
          show_presets = false
          show_step_section = false
          show_text_controls = true
          show_settings_section = false
          show_delay_sliders = false
          show_marker_opacity_section = false
          context_aware_ui = true
          show_preset_toasts = true
          show_tool_preview = false
          top_offset = 955.53
          top_offset_y = -16.0
          side_offset = 77.89
          side_offset_x = 11.14
          force_inline = false

          [ui.toolbar.mode_overrides.simple]

          [ui.toolbar.mode_overrides.regular]

          [ui.toolbar.mode_overrides.advanced]

          [presenter_mode]
          hide_status_bar = true
          hide_toolbars = true
          hide_tool_preview = true
          close_help_overlay = true
          enable_click_highlight = true
          tool_behavior = "force-highlight"
          show_toast = true

          [boards]
          max_count = 9
          auto_create = true
          show_board_badge = true
          persist_customizations = true
          default_board = "transparent"

          [[boards.items]]
          id = "transparent"
          name = "Overlay"
          background = "transparent"
          auto_adjust_pen = false
          persist = true
          pinned = false

          [[boards.items]]
          id = "whiteboard"
          name = "Whiteboard"
          background = ${rgbFloat3 fg}
          default_pen_color = ${rgbFloat3 bg}
          auto_adjust_pen = true
          persist = true
          pinned = false

          [[boards.items]]
          id = "blackboard"
          name = "Blackboard"
          background = ${rgbFloat3 bg}
          default_pen_color = ${rgbFloat3 fg}
          auto_adjust_pen = true
          persist = true
          pinned = false

          [[boards.items]]
          id = "blueprint"
          name = "Blueprint"
          background = [0.063, 0.125, 0.251]
          default_pen_color = ${rgbFloat3 fg}
          auto_adjust_pen = true
          persist = true
          pinned = false

          [[boards.items]]
          id = "corkboard"
          name = "Corkboard"
          background = [0.42, 0.294, 0.165]
          default_pen_color = ${rgbFloat3 fg}
          auto_adjust_pen = true
          persist = true
          pinned = false

          [board]
          enabled = true
          default_mode = "transparent"
          whiteboard_color = ${rgbFloat3 fg}
          blackboard_color = ${rgbFloat3 bg}
          whiteboard_pen_color = ${rgbFloat3 bg}
          blackboard_pen_color = ${rgbFloat3 fg}
          auto_adjust_pen = true

          [keybindings]
          exit = ["Escape", "Ctrl+Q"]
          enter_text_mode = ["T"]
          enter_sticky_note_mode = ["N"]
          clear_canvas = ["E"]
          undo = ["Ctrl+Z"]
          redo = ["Ctrl+Shift+Z", "Ctrl+Y"]
          undo_all = []
          redo_all = []
          undo_all_delayed = []
          redo_all_delayed = []
          duplicate_selection = ["Ctrl+D"]
          copy_selection = ["Ctrl+Alt+C"]
          paste_selection = ["Ctrl+Alt+V"]
          select_all = ["Ctrl+A"]
          move_selection_to_front = ["]"]
          move_selection_to_back = ["["]
          nudge_selection_up = ["ArrowUp"]
          nudge_selection_down = ["ArrowDown"]
          nudge_selection_left = ["ArrowLeft", "Shift+PageUp"]
          nudge_selection_right = ["ArrowRight", "Shift+PageDown"]
          nudge_selection_up_large = ["PageUp"]
          nudge_selection_down_large = ["PageDown"]
          move_selection_to_start = ["Home"]
          move_selection_to_end = ["End"]
          move_selection_to_top = ["Ctrl+Home"]
          move_selection_to_bottom = ["Ctrl+End"]
          delete_selection = ["Delete"]
          increase_thickness = ["+", "="]
          decrease_thickness = ["-", "_"]
          increase_marker_opacity = ["Ctrl+Alt+ArrowUp"]
          decrease_marker_opacity = ["Ctrl+Alt+ArrowDown"]
          select_selection_tool = ["V"]
          select_marker_tool = ["H"]
          select_step_marker_tool = []
          select_eraser_tool = ["D"]
          toggle_eraser_mode = ["Ctrl+Shift+E"]
          select_pen_tool = ["F"]
          select_line_tool = []
          select_rect_tool = []
          select_ellipse_tool = []
          select_arrow_tool = []
          select_highlight_tool = []
          toggle_highlight_tool = ["Ctrl+Alt+H"]
          increase_font_size = ["Ctrl+Shift++", "Ctrl+Shift+="]
          decrease_font_size = ["Ctrl+Shift+-", "Ctrl+Shift+_"]
          reset_arrow_labels = ["Ctrl+Shift+R"]
          reset_step_markers = []
          toggle_whiteboard = ["Ctrl+W"]
          toggle_blackboard = ["Ctrl+B"]
          return_to_transparent = ["Ctrl+Shift+T"]
          page_prev = ["Ctrl+Alt+ArrowLeft", "Ctrl+Alt+PageUp"]
          page_next = ["Ctrl+Alt+ArrowRight", "Ctrl+Alt+PageDown"]
          page_new = ["Ctrl+Alt+N"]
          page_duplicate = ["Ctrl+Alt+D"]
          page_delete = ["Ctrl+Alt+Delete"]
          board_1 = ["Ctrl+Shift+1"]
          board_2 = ["Ctrl+Shift+2"]
          board_3 = ["Ctrl+Shift+3"]
          board_4 = ["Ctrl+Shift+4"]
          board_5 = ["Ctrl+Shift+5"]
          board_6 = ["Ctrl+Shift+6"]
          board_7 = ["Ctrl+Shift+7"]
          board_8 = ["Ctrl+Shift+8"]
          board_9 = ["Ctrl+Shift+9"]
          board_next = ["Ctrl+Shift+ArrowRight"]
          board_prev = ["Ctrl+Shift+ArrowLeft"]
          board_new = ["Ctrl+Shift+N"]
          board_duplicate = ["Ctrl+Shift+D"]
          board_delete = ["Ctrl+Shift+Delete"]
          board_picker = ["Ctrl+Shift+B"]
          toggle_help = ["F10", "F1"]
          toggle_quick_help = ["Shift+F1"]
          toggle_status_bar = ["F12", "F4"]
          toggle_click_highlight = ["Ctrl+Shift+H"]
          toggle_toolbar = ["F2", "F9"]
          toggle_presenter_mode = ["Ctrl+Shift+M"]
          toggle_fill = []
          toggle_selection_properties = ["Ctrl+Alt+P"]
          open_context_menu = ["Shift+F10", "Menu"]
          open_configurator = ["F11"]
          toggle_command_palette = ["Ctrl+K"]
          set_color_red = ["R"]
          set_color_green = ["G"]
          set_color_blue = ["B"]
          set_color_yellow = ["Y"]
          set_color_orange = ["O"]
          set_color_pink = ["P"]
          set_color_white = ["W"]
          set_color_black = ["K"]
          capture_full_screen = ["Ctrl+Shift+P"]
          capture_active_window = ["Ctrl+Shift+O"]
          capture_selection = ["Ctrl+Shift+I"]
          capture_clipboard_full = ["Ctrl+C"]
          capture_file_full = ["Ctrl+S"]
          capture_clipboard_selection = ["Ctrl+Shift+C"]
          capture_file_selection = ["Ctrl+Shift+S"]
          capture_clipboard_region = ["Ctrl+6"]
          capture_file_region = ["Ctrl+Alt+6"]
          open_capture_folder = ["Ctrl+Alt+O"]
          toggle_frozen_mode = ["Ctrl+Shift+F"]
          zoom_in = ["Ctrl+Alt++", "Ctrl+Alt+="]
          zoom_out = ["Ctrl+Alt+-", "Ctrl+Alt+_"]
          reset_zoom = ["Ctrl+Alt+0"]
          toggle_zoom_lock = ["Ctrl+Alt+L"]
          refresh_zoom_capture = ["Ctrl+Alt+R"]
          apply_preset_1 = ["1"]
          apply_preset_2 = ["2"]
          apply_preset_3 = ["3"]
          apply_preset_4 = ["4"]
          apply_preset_5 = ["5"]
          save_preset_1 = ["Shift+1"]
          save_preset_2 = ["Shift+2"]
          save_preset_3 = ["Shift+3"]
          save_preset_4 = ["Shift+4"]
          save_preset_5 = ["Shift+5"]
          clear_preset_1 = ["Ctrl+1"]
          clear_preset_2 = ["Ctrl+2"]
          clear_preset_3 = ["Ctrl+3"]
          clear_preset_4 = ["Ctrl+4"]
          clear_preset_5 = ["Ctrl+5"]

          [capture]
          enabled = true
          save_directory = "~/Pictures/Wayscriber"
          filename_template = "screenshot_%Y-%m-%d_%H%M%S"
          format = "png"
          copy_to_clipboard = true
          exit_after_capture = false

          [tablet]
          enabled = false
          pressure_enabled = true
          min_thickness = 1.0
          max_thickness = 8.0
          auto_eraser_switch = true
          pressure_variation_threshold = 0.1
          pressure_thickness_edit_mode = "disabled"
          pressure_thickness_entry_mode = "pressure_only"
          pressure_thickness_scale_step = 0.1

          [session]
          persist_transparent = true
          persist_whiteboard = true
          persist_blackboard = true
          persist_history = true
          restore_tool_state = true
          autosave_enabled = true
          autosave_idle_ms = 5000
          autosave_interval_ms = 45000
          autosave_failure_backoff_ms = 5000
          storage = "auto"
          max_shapes_per_frame = 10000
          max_file_size_mb = 10
          compress = "auto"
          auto_compress_threshold_kb = 100
          backup_retention = 1
          per_output = true
        '';

      systemd.user.services.wayscriber = {
        Unit = {
          Description = "Wayscriber";
          Wants = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.unstable.wayscriber}/bin/wayscriber --daemon";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 5;
        };
      };

      programs.wlr-which-key.config.menu = [
        {
          key = "a";
          desc = "Annotate screen";
          cmd = "pkill -SIGUSR1 wayscriber";
        }
      ];
    };
}
