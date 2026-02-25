{ ... }:
{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.git-filter-repo ];

      programs.git = {
        enable = true;
        lfs.enable = true;

        settings = {
          user.email = "m4xv3rb33k@gmail.com";
          user.name = "Max Verbeek";

          pull.rebase = "false";
          push.default = "current";
          push.autoSetupRemote = "true";
          init.defaultBranch = "master";
          submodule.recurse = "true";
          url."git@github.com:rug-ds-lab".insteadOf = "https://github.com/rug-ds-lab";
          url."git@github.com:ecida".insteadOf = "https://github.com/ecida";
          url."git@gitlab.com:researchable".insteadOf = "https://gitlab.com/researchable";
          url."git@gitlab.com:axtion".insteadOf = "https://gitlab.com/axtion";

          alias = {
            s = "status";
            cm = "commit -m";
            co = "checkout";
            l = "pull --rebase";
            lm = "pull";
            a = "add";
            brd = "!git fetch -p && git branch -vv | awk '!/*/ && /: gone]/ {print $1}' | xargs git branch -d";
            difflast = "diff HEAD^";
            mp = ''!git push -o merge_request.create 2>&1 | xtee -p "https://\\S+" -e wl-copy -e xdg-open >&2'';
            mpr = ''!f() { git push -o merge_request.create -o "merge_request.description=/assign_reviewer @$1" 2>&1 | xtee -p "https://\\S+" -e wl-copy -e xdg-open >&2; }; f'';
            mprf = ''!f() { reviewer=$(gitlab-reviewer | fzf --with-nth=1 --delimiter=$'\t' | cut -f2) || return; [ -n "$reviewer" ] && git mpr "$reviewer"; }; f'';
            gfp = "push --force-with-lease --force-if-includes";
            sm = "!git switch master || git switch main";
            sd = "!git switch develop || git switch development || git switch beta";
          };
        };

        ignores = [
          "**/.claude/settings.local.json"
          ".direnv"
        ];
      };

      programs.delta.enable = false;

      programs.difftastic = {
        enable = true;
        git.enable = true;
      };
    };
}
