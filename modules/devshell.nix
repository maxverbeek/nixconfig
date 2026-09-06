{ ... }:
{
  perSystem =
    { pkgs, inputs', ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          inputs'.agenix.packages.default
          inputs'.disko.packages.default
          pkgs.nixos-anywhere
          pkgs.git
        ];
      };
    };
}
