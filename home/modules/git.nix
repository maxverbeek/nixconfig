{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
{
  options = {
    modules.git.enable = mkEnableOption "Enable Git config";
  };

  config = mkIf config.modules.git.enable {
    home.packages = [ pkgs.git-filter-repo ];
    programs.git = {
      enable = true;

      lfs.enable = true;

      userEmail = "m4xv3rb33k@gmail.com";
      userName = "Max Verbeek";

      extraConfig = {
        pull.rebase = "false";
        push.default = "current";
        push.autoSetupRemote = "true";
        init.defaultBranch = "master";

        # recursively clone submodules
        submodule.recurse = "true";

        url."git@github.com:rug-ds-lab".insteadOf = "https://github.com/rug-ds-lab";
        url."git@github.com:ecida".insteadOf = "https://github.com/ecida";
        url."git@gitlab.com:researchable".insteadOf = "https://gitlab.com/researchable";
        url."git@gitlab.com:axtion".insteadOf = "https://gitlab.com/axtion";
      };

      delta.enable = false;
      difftastic.enable = true;

      aliases = {
        s = "status";
        cm = "commit -m";
        co = "checkout";
        a = "add";
        # The !/*/ is a regex that excludes the literal '*' (current branch),
        # and /: gone/ includes branches that are gone on the remote.
        brd = "!git fetch -p && git branch -vv | awk '!/*/ && /: gone]/ {print $1}' | xargs git branch -d";

        difflast = "diff HEAD^";

        # see: github.com/maxverbeek/xtee
        mp = ''!git push -o merge_request.create 2>&1 | xtee -p "https://\\S+" -e wl-copy >&2'';

        gfp = "push --force-with-lease --force-if-includes";
      };
    };
  };
}
