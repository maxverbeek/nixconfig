{
  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          pythonPackages = pkgs.python312Packages;
        in
        {
          default = pkgs.mkShell {
            name = "pyenv";
            venvDir = "./.venv";

            buildInputs = [
              pythonPackages.python
              pythonPackages.venvShellHook
            ];

            postVenvCreation = ''
              unset SOURCE_DATE_EPOCH
            '';

            postShellHook = ''
              unset SOURCE_DATE_EPOCH
              export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
            '';
          };
        }
      );
    };
}
