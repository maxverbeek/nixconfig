{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.modules.kubectl;
in
{
  options.modules.kubectl = {
    enable = lib.mkEnableOption "kubectl";

    enableKubeseal = lib.mkOption {
      type = lib.types.bool;
      description = "Enable kubeseal for sealed secrets";
      default = true;
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      description = "Enable ZSH shell completions for kubectl";
      default = true;
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      description = "Enable bash shell completions for kubectl";
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kubectl
      pkgs.kubectl-cnpg
      pkgs.cmctl
      pkgs.k9s

      (pkgs.wrapHelm pkgs.kubernetes-helm {
        plugins = [
          pkgs.kubernetes-helmPlugins.helm-diff
        ];
      })
    ] ++ lib.optional cfg.enableKubeseal pkgs.kubeseal;

    programs.zsh.initContent = lib.mkIf cfg.enableZshIntegration ''
      source <(kubectl completion zsh)
      source <(helm completion zsh)
      source <(helm diff completion zsh)
    '';

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
      source <(kubectl completion bash)
      source <(helm completion zsh)
      source <(helm diff completion zsh)
    '';
  };
}
