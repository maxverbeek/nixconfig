{ ... }:
{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        corefonts
        custom.fa-custom
        custom.teg-font
        hack-font
        noto-fonts
        powerline-fonts
        roboto
        roboto-mono
        source-code-pro
        terminus_font
        ubuntu-classic
        nerd-fonts.jetbrains-mono
      ];
    };
}
