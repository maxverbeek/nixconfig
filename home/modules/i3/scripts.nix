{ config, pkgs, lib }:
let
  # helpers to quickly get screen attributes
  screens = config.device.screens;
  screen = with builtins; x: (elemAt screens x).name;
  primscreen = with builtins; x: (elemAt screens x).isPrimary;

in {
  # take care that this script isnt evaluated when there is only 1 screen configured
  # assume that only 1 screen is connected, otherwise this becomes much more complicated
  fixscreens = pkgs.writeScriptBin "fixscreens" ''
    #!${pkgs.stdenv.shell}
    xrandr | grep -q "${screen 1} connected"
    ST=$?

    if [ $ST -eq 0 ]; then
      xrandr \
        --output ${screen 0} \
        --auto \
        ${lib.optionalString (primscreen 0) "--primary"} \
        --output ${screen 1} \
        --auto \
        ${lib.optionalString (primscreen 1) "--primary"} \
        --right-of ${screen 0}
    else
      xrandr --auto
    fi

    $HOME/.fehbg
  '';

  mirror = pkgs.writeScriptBin "mirror" ''
    #!${pkgs.stdenv.shell}
    xrandr | grep -q "${screen 1} connected"
    ST=$?

    if [ $ST -eq 0 ]; then
      xrandr \
        --output ${screen 0} \
        ${lib.optionalString (primscreen 0) "--primary"} \
        ${lib.optionalString (primscreen 1) "--same-as ${screen 1}"} \
        --auto \
        --output ${screen 1} \
        ${lib.optionalString (primscreen 1) "--primary"} \
        ${lib.optionalString (primscreen 0) "--same-as ${screen 0}"} \
        --auto
    else
      xrandr --auto
    fi

    $HOME/.fehbg
  '';
}
