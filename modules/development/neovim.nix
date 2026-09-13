{
  flake.modules.nixos.development =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.self.nvim-mutable
        pkgs.self.nvim
      ];
    };
}
