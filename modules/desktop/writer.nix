{
  flake.modules.nixos.headful =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        abiword
        libreoffice
      ];
    };
}
