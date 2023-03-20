{ pkgs, config, lib, ... }:
let
  inherit (config.lib.formats.rasi) mkLiteral;

  kanagawa = pkgs.custom.kanagawa-nvim.colors.term;

  colors = {
    black = kanagawa.normal.black;
    red = kanagawa.normal.red;
    green = kanagawa.normal.green;
    yellow = kanagawa.bright.yellow;
    blue = kanagawa.normal.blue;
    magenta = kanagawa.normal.purple;
    cyan = kanagawa.bright.blue;
    emphasis = kanagawa.extended.slate;
    text = kanagawa.bright.white;
    text-alt = kanagawa.normal.white;
    fg = kanagawa.normal.white;
    bg = kanagawa.extended.background;
  };

  themefile = pkgs.writeText "theme.rasi" ''
    * {
      black:      ${colors.black};
      red:        ${colors.red};
      green:      ${colors.green};
      yellow:     ${colors.yellow};
      blue:       ${colors.blue};
      mangenta:   ${colors.magenta};
      purple:     ${colors.magenta};
      cyan:       ${colors.cyan};
      emphasis:   ${colors.emphasis};
      text:       ${colors.text};
      text-alt:   ${colors.text-alt};
      fg:         ${colors.fg};
      bg:         ${colors.bg};

      spacing: 0;
      background-color: transparent;

      font: "JetBrainsMono Nerd Font 12";
      text-color: @text;
    }

    window {
      transparency: "real";
      background-color: @bg;
    }

    mainbox {
      padding: 20px;
      border: 2px;
      border-color: @blue;
    }

    inputbar {
      margin: 0px 0px 10px 0px;
      padding: 0 0 10px 0;
      children: [prompt, textbox-prompt-colon, entry, case-indicator];
      border: 0 0 1;
      border-color: @fg;
    }

    prompt {
      text-color: @blue;
    }

    textbox-prompt-colon {
      expand: false;
      str: ":";
      text-color: @text-alt;
    }

    entry {
      margin: 0px 10px;
    }

    listview {
      spacing: 3px;
      dynamic: true;
      scrollbar: false;
    }

    element {
      padding: 6px;
      text-color: @text-alt;
      highlight: bold ${colors.green};
      border-radius: 3px;
    }

    element-icon {
      size: 20;
      padding: 0 5px 0 0;
    }

    element selected {
      background-color: @emphasis;
      text-color: @text;
    }

    element urgent, element selected urgent {
      text-color: @red;
    }

    element active, element selected active {
      text-color: @purple;
    }

    message {
      padding: 5px;
      border-radius: 3px;
      background-color: @emphasis;
      border: 1px;
      border-color: @cyan;
    }

    button selected {
      padding: 5px;
      border-radius: 3px;
      background-color: @emphasis;
    }
  '';
in {
  options = { modules.rofi.enable = lib.mkEnableOption "Enable rofi"; };

  config = lib.mkIf config.modules.rofi.enable {
    programs.rofi = {
      enable = true;

      font = "JetBrainsMono Nerd Font 12";

      terminal = "${pkgs.alacritty}/bin/alacritty";

      extraConfig = {
        modi = "drun,run,window";
        separator-style = "solid";
        show-match = false;
      };

      theme = "${themefile}";
    };

  };
}
