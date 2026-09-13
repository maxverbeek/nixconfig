{ ... }:
{
  flake.modules.nixos.base = {
    # System-wide /etc/ssh/ssh_config: also applies to root. The
    # IdentityFile paths are max's; single-user machines, fine.
    programs.ssh.extraConfig = ''
      Host *
        SetEnv TERM=xterm-256color

      Host pg-gpu.hpc.rug.nl
        User f119970

      Host themis
        HostName themis.housing.rug.nl
        User themis
        IdentityFile /home/max/.ssh/laptop_rsa

      Host ssh.dev.azure.com
        PubkeyAcceptedKeyTypes +ssh-rsa
        HostkeyAlgorithms +ssh-rsa

      Host researchable-1
        HostName 176.9.32.68
        User root
        IdentityFile /home/max/.ssh/hetzner_researchable

      Host researchable-2
        HostName 176.9.48.16
        User root
        IdentityFile /home/max/.ssh/hetzner_researchable
    '';

    programs.gnupg.agent.enable = true;
  };
}
