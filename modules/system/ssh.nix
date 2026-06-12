{ ... }:
{
  flake.modules.homeManager.base = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*".SetEnv = {
          TERM = "xterm-256color";
        };

        "pg-gpu.hpc.rug.nl".User = "f119970";

        "themis" = {
          HostName = "themis.housing.rug.nl";
          User = "themis";
          IdentityFile = "/home/max/.ssh/laptop_rsa";
        };

        "ssh.dev.azure.com" = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
          HostkeyAlgorithms = "+ssh-rsa";
        };

        "researchable-1" = {
          HostName = "176.9.32.68";
          User = "root";
          IdentityFile = "/home/max/.ssh/hetzner_researchable";
        };

        "researchable-2" = {
          HostName = "176.9.48.16";
          User = "root";
          IdentityFile = "/home/max/.ssh/hetzner_researchable";
        };
      };
    };

    programs.gpg.enable = true;
    services.gpg-agent.enable = true;
  };
}
