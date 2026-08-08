{
  flake.modules.nixos.harmonia =
    { pkgs, ... }:
    {
      # Binary cache for the other hosts, reachable over tailscale only
      # (port 5000; tailscale0 is a trusted interface, public firewall stays closed).
      # Key uploaded by secrets/harmonia-signing-key.sh
      services.harmonia = {
        enable = true;
        signKeyPaths = [ "/var/secrets/harmonia-signing-key" ];
      };

      # Pre-build the desktop closures after each nightly upgrade so laptops
      # can substitute instead of compiling. Out-links keep them GC-rooted.
      systemd.services.nixos-upgrade.onSuccess = [ "prebuild-hosts.service" ];
      systemd.services.prebuild-hosts = {
        description = "Pre-build desktop host closures for the binary cache";
        path = [
          pkgs.nix
          pkgs.git
          pkgs.openssh
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          for host in desknix thinkpad; do
            nix build --refresh --out-link "/var/lib/prebuilt-$host" \
              "github:maxverbeek/nixconfig#nixosConfigurations.$host.config.system.build.toplevel"
          done

          # extra packages listed in modules/server/cache-contents.nix
          nix build --refresh --out-link /var/lib/prebuilt-cache \
            "github:maxverbeek/nixconfig#cache"
        '';
      };
    };
}
