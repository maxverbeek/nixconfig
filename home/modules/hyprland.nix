{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.hyprland;
  rofi-cliphist = pkgs.writeScriptBin "rofi-cliphist" ''
    #!/usr/bin/env bash

    tmp_dir="/tmp/cliphist"
    rm -rf "$tmp_dir"

    if [[ -n "$1" ]]; then
        cliphist decode <<<"$1" | wl-copy
        exit
    fi

    mkdir -p "$tmp_dir"

    read -r -d "" prog <<EOF
    /^[0-9]+\s<meta http-equiv=/ { next }
    match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
        system("echo " grp[1] "\\\\\t | cliphist decode >$tmp_dir/"grp[1]"."grp[3])
        print \$0"\0icon\x1f$tmp_dir/"grp[1]"."grp[3]
        next
    }
    1
    EOF
    cliphist list | gawk "$prog"

  '';
in
{

  options.modules.hyprland.enable = lib.mkEnableOption null;

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
      xwayland.enable = true;
      extraConfig = ''
        source = ~/.config/hypr/actualconfig.conf
      '';

      # plugins = with pkgs.hyprlandPlugins; [ hy3 ];
    };

    home.sessionVariables = {
      # set screenshot editor to something lightweight
      GRIMBLAST_EDITOR = "kolourpaint";
    };

    home.packages = with pkgs; [
      swaybg
      xdg-launch # xdg-open
      xdg-utils
      swaylock
      swayidle

      cliphist
      wl-clipboard
      wl-clip-persist
      rofi-cliphist # thing that shows clip history in rofi (from cliphist)
      wf-recorder
      slurp

      # screenshots
      grimblast
    ];
  };
}
