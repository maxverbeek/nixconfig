{ pkgs, ... }: {
  programs.zsh = {
    enable = true;

    # set this because it's already enabled in HM and this causes cache
    # invalidation that slows down zsh startup time
    enableCompletion = false;
  };

  users.users.max.shell = pkgs.zsh;
}
