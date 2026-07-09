{
  description = "Flakey flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";

    # xtee try out thingy
    xtee.url = "github:maxverbeek/xtee";

    gitlab-reviewer.url = "github:maxverbeek/gitlab-reviewer";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";

    opencode.url = "github:anomalyco/opencode/v1.15.0";
    opencode.inputs.nixpkgs.follows = "unstable";

    # don't follow nixpkgs here, to keep the cachix binary cache usable
    claude-code.url = "github:sadjow/claude-code-nix";

    # hyprland.url = "github:hyprwm/Hyprland?ref=refs/tags/v0.40.0";
    # text2url.url = "github:maxverbeek/text2url";
    # ags.url = "github:Aylur/ags?ref=refs/tags/v2.3.0";
    ags.url = "github:maxverbeek/astalconfig";

    # walker + elephant stuff
    walker.url = "github:abenz1267/walker";
    walker.inputs.elephant.follows = "elephant";

    elephant.url = "github:abenz1267/elephant";
    elephant.inputs.nixpkgs.follows = "unstable";

    elephant-gitlab.url = "github:maxverbeek/elephant-gitlab";
    elephant-gitlab.inputs.elephant.follows = "elephant";
    elephant-gitlab.inputs.nixpkgs.follows = "unstable";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    feedbackers.url = "git+ssh://git@github.com/maxverbeek/feedbackers";
    feedbackers.inputs.nixpkgs.follows = "nixpkgs";

    breadhero.url = "git+ssh://git@github.com/maxverbeek/breadhero";
    breadhero.inputs.nixpkgs.follows = "nixpkgs";

    stalker.url = "git+ssh://git@github.com/maxverbeek/stalker";
    stalker.inputs.nixpkgs.follows = "unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
