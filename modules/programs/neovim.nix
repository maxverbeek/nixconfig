{
  nixos.programs.neovim =
    { my, ... }:
    {
      environment.systemPackages = [
        my.pkgs.wrapped.nvim-mutable
        my.pkgs.wrapped.nvim
      ];
    };
}
