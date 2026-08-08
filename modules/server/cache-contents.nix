{ ... }:
{
  # Extra derivations the VPS pre-builds for the binary cache, beyond the host
  # closures (which already cover everything installed on a host). Add anything
  # here that you want pre-compiled: `nix build .#cache` realises the whole list.
  perSystem =
    { pkgs, inputs', ... }:
    {
      packages.cache = pkgs.linkFarm "binary-cache-contents" (
        pkgs.lib.mapAttrsToList (name: path: { inherit name path; }) {
          xtee = inputs'.xtee.packages.default;
          copd = inputs'.copd.packages.default;
          gitlab-reviewer = inputs'.gitlab-reviewer.packages.default;
          feedbackers = inputs'.feedbackers.packages.default;
          breadhero = inputs'.breadhero.packages.default;
          stalker = inputs'.stalker.packages.default;
          barbell = inputs'.barbell.packages.default;
          elephant-gitlab = inputs'.elephant-gitlab.packages.default;
          astalconfig = inputs'.ags.packages.default;
        }
      );
    };
}
