{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.self.nvim-mutable
        pkgs.self.nvim
      ];
    };
}
