{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.self.nvim-mutable
        pkgs.self.nvim
      ];
    };
}
