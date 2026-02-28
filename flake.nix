{
  description = "Flakey flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";

    # xtee try out thingy
    xtee.url = "github:maxverbeek/xtee";

    gitlab-reviewer.url = "github:maxverbeek/gitlab-reviewer";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";

    opencode.url = "github:anomalyco/opencode?ref=refs/tags/v1.2.14";
    opencode.inputs.nixpkgs.follows = "unstable";

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
    import-tree.url = "github:vic/import-tree";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
