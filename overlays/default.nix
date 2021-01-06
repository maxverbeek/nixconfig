{ pkgs, ... }:

let customOverlays = final: prev: {
  fa-custom = pkgs.callPackage (import ./fontawesome-custom) {};
};
in
{
  nixpkgs.overlays = [ customOverlays ];
}
