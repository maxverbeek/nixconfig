{
  flake.modules.nixos.harmonia =
    { config, pkgs, ... }:
    {
      age.secrets.harmonia-signing-key.file = ../../secrets/harmonia-signing-key.age;

      # Binary cache for the other hosts, reachable over tailscale only
      # (port 5000; tailscale0 is a trusted interface, public firewall stays closed).
      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [ config.age.secrets.harmonia-signing-key.path ];
      };

      # Pre-build the shared packages after each nightly upgrade so laptops can
      # substitute instead of compiling. Not the desktop toplevels: two full
      # closures a night is ~30G on a 75G disk, which filled it to 100%.
      systemd.services.nixos-upgrade.onSuccess = [ "prebuild-hosts.service" ];
      systemd.services.prebuild-hosts = {
        description = "Pre-build shared packages for the binary cache";
        path = [
          pkgs.nix
          pkgs.git
          pkgs.openssh
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          # packages listed in modules/server/cache-contents.nix
          nix build --refresh --out-link /var/lib/prebuilt-cache \
            "github:maxverbeek/nixconfig#cache"
        '';
      };
    };
}
