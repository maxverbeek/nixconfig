{ config, pkgs, lib, ... }:

with lib;

let

  # Not to be confused with config.services.picom, which is home-managers
  # default thing, which suckss.
  cfg = config.modules.picom;

  # Todo: add some configurable things to this
  configFile = pkgs.writeText "picom.conf" ''
    backend = "glx";

    glx-no-stencil = true;
    glx-copy-from-front = false;
    glx-no-rebind-pixmap = true;
    
    vsync = true;
    
    unredir-if-possible = true;
    
    shadow = true;
    shadow-radius = 6;
    shadow-opacity = 0.4
    shadow-offset-x = -4;
    shadow-offset-y = -6;
    
    shadow-exclude = [
      "name = 'Polybar tray window'",
      "class_g = 'Bspwm' && class_i = 'presel_feedback'"
    ];
    
    mark-overdir-focused = true;
    frame-opacity = 0.3;
    inactive-opacity = 0.87;
    inactive-opacity-override = false;
    
    opacity-rule = [
        "40:class_g = 'Bspwm' && class_i = 'presel_feedback'",
    ];
    
    focus-exclude = [
        "name = 'i3lock'"
    ]
    
    blur-background = true;
    blur-method = "dual_kawase"
    blur-strength = 8;
    blur-background-exclude = "( !window_type = 'dock' && !class_g = 'Dunst' )";
    
    wintypes: {
      tooltip = { fade = true; shadow = false; }
      menu = { shadow = false; }
      dropdown_menu = { shadow = false; }
      popup_menu = { shadow = false; }
      dock = { shadow = false; }
      splash = { shadow = false; }
      utility = { shadow = false; }
      dnd = { shadow = false; }
    }
  '';

  backendFlag = optionalString cfg.experimentalBackends " --experimental-backends";

in
{
  options.modules.picom = {
    enable = mkEnableOption "Enable Picom X11 compositor";

    package = mkOption {
      type = types.package;
      default = pkgs.picom;
      defaultText = literalExample "pkgs.picom";
      example = literalExample "pkgs.picom";
      description = "Picom derivation package to use";
    };

    experimentalBackends = mkOption {
      type = types.bool;
      default = true;
      defaultText = literalExample "true";
      example = literalExample "true";
      description = "Enable (true) or disable (false) experimental backends";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.picom = {
      Unit = {
        Description = "Picom X11 compositor";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];

      Service = {
        ExecStart = "${cfg.package}/bin/picom --config ${configFile}" + backendFlag;
        Restart = "always";
        RestartSec = "3";
      };
    };
  };
}
