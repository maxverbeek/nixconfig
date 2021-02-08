{ lib, fetchurl, appimageTools }:

appimageTools.wrapType2 {
  name = "responsively";
  src = fetchurl {
    url = "https://github.com/responsively-org/responsively-app/releases/download/v0.15.0/ResponsivelyApp-0.15.0.AppImage";
    sha256 = "sha256-/GUj2tjdAF6rfCwO49yhNPVjwOQazX5IX3BShcd5NYA=";
  };
}
