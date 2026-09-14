{ lib }:
{
  # "#RRGGBB" -> { r, g, b } in 0-255
  hexToRgb =
    hex:
    let
      byte = i: lib.fromHexString (builtins.substring i 2 hex);
    in
    {
      r = byte 1;
      g = byte 3;
      b = byte 5;
    };
}
