{
  flake.modules.homeManager.headful =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        abiword
        libreoffice
      ];
    };
}
