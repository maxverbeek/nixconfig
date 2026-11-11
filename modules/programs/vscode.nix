{
  nixos.programs.vscode =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        # VSCode 1.144 moved its bundled rg; nixpkgs' postPatch still rm's the old path.
        # Drop once nixpkgs fixes it.
        ((pkgs.vscode.overrideAttrs (o: {
          postPatch =
            builtins.replaceStrings
              [ "resources/app/node_modules/@vscode/ripgrep/bin/rg" ]
              [ "resources/app/node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/linux-x64/rg" ]
              o.postPatch;
        })).fhsWithPackages (
          ps: with ps.vscode-extensions; [
            dbaeumer.vscode-eslint
            eamodio.gitlens
            ms-azuretools.vscode-docker
            ms-vsliveshare.vsliveshare
            vscodevim.vim
          ]
        ))
      ];
    };
}
