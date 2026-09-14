{
  nixos.programs.ssh =
    { pkgs, ... }:
    {
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

      programs.gnupg.agent = {
        enable = true;
        settings.grab = true;
      };

      # gpg 2.4 reads no global gpg.conf, so the user's file is a symlink into
      # the store; gpg wants the directory itself to be 0700.
      systemd.user.tmpfiles.users.max.rules = [
        "d %h/.gnupg 0700 - - -"
        "L+ %h/.gnupg/gpg.conf - - - - ${pkgs.writeText "gpg.conf" ''
          cert-digest-algo SHA512
          default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
          display-charset utf-8
          keyid-format 0xlong
          list-options show-uid-validity
          no-comments
          no-emit-version
          no-symkey-cache
          personal-cipher-preferences AES256 AES192 AES
          personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
          personal-digest-preferences SHA512 SHA384 SHA256
          require-cross-certification
          s2k-cipher-algo AES256
          s2k-digest-algo SHA512
          verify-options show-uid-validity
          with-fingerprint
        ''}"
      ];
    };
}
