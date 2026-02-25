{ ... }:
{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "pg-gpu.hpc.rug.nl" = {
          user = "f119970";
        };

        "themis" = {
          hostname = "themis.housing.rug.nl";
          user = "themis";
          identityFile = "/home/max/.ssh/laptop_rsa";
        };

        "ssh.dev.azure.com".extraOptions = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
          HostkeyAlgorithms = "+ssh-rsa";
        };

        "researchable-1" = {
          hostname = "176.9.32.68";
          user = "root";
          identityFile = "/home/max/.ssh/hetzner_researchable";
        };

        "researchable-2" = {
          hostname = "176.9.48.16";
          user = "root";
          identityFile = "/home/max/.ssh/hetzner_researchable";
        };
      };
    };

    programs.gpg.enable = true;
    services.gpg-agent.enable = true;

    programs.go = {
      enable = true;
      env = {
        GOPATH = "go";
        GOBIN = "go/bin";
      };
    };
  };
}
