{ pkgs, config, lib, ... }:

let cfg = config.modules.kubectl;
in {
  options.modules.kubectl = {
    enable = lib.mkEnableOption "kubectl";

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
    home.packages = [ pkgs.kubectl ];

    programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration ''
      source <(kubectl completion zsh)
    '';

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
      source <(kubectl completion bash)
    '';
  };
}
