{
  nixos.programs.office =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        abiword
        libreoffice
      ];
    };
}
