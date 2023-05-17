{ pkgs, lib, config, ... }:
with lib; {
  options = { modules.vscode.enable = mkEnableOption "Enable VSCode"; };

  config = mkIf config.modules.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (ps:
        with ps.vscode-extensions; [
          # bbenoist.Nix # gone?
          dbaeumer.vscode-eslint # not in unstable yet?
          eamodio.gitlens
          # editorconfig.editorconfig # not in master yet
          # firefox-devtools.vscode-firefox-debug # not in master yet
          ms-azuretools.vscode-docker
          ms-vsliveshare.vsliveshare
          vscodevim.vim
        ]);
    };
  };
}
