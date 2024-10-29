{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    # set this because it's already enabled in HM and this causes cache
    # invalidation that slows down zsh startup time
    enableCompletion = false;
  };

  # from the docs of home-manager zsh: to get completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  users.users.max.shell = pkgs.zsh;
}
