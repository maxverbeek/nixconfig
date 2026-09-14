{
  nixos.programs.git =
    { my, pkgs, ... }:
    {
      environment.systemPackages = [
        my.pkgs.wrapped.git
        pkgs.git-lfs # `git lfs ...` subcommands look it up on PATH
        pkgs.difftastic
        pkgs.git-filter-repo
        pkgs.mr
      ];
    };
}
