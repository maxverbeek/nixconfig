{
  # Dev tooling: editors, languages, CLIs, the coding agents, and the two
  # virtualisation daemons a dev box needs. Today's development + docker.
  nixos.collections.development =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        programs.git
        programs.neovim
        programs.python
        programs.go
        programs.kubectl
        programs.direnv
        programs.vscode
        programs.gog
        programs.dev-tools
        programs.claude
        programs.agents
        programs.bitwarden
        services.docker
        services.libvirt
      ];
    };
}
