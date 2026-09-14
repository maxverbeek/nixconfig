{
  nixos.system.fonts =
    { my, pkgs, ... }:
    {
      fonts.packages = [
        pkgs.corefonts
        my.pkgs.fa-custom
        my.pkgs.teg-font
        pkgs.hack-font
        pkgs.inter
        pkgs.noto-fonts
        pkgs.powerline-fonts
        pkgs.roboto
        pkgs.roboto-mono
        pkgs.source-code-pro
        pkgs.terminus_font
        pkgs.ubuntu-classic
        pkgs.nerd-fonts.jetbrains-mono
      ];

      console = {
        font = "Lat2-Terminus16";
        useXkbConfig = true;
      };
    };
}
