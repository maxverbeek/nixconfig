{ inputs, ... }:
{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.self.packages.${pkgs.system}.nvim-mutable
        inputs.self.packages.${pkgs.system}.nvim-immut
      ];
    };
}
