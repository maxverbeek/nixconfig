{
  nixos.programs.vscode =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.vscode.fhsWithPackages (
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
