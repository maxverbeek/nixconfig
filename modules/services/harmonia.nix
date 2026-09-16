{
  nixos.services.harmonia =
    {
      config,
      pkgs,
      my,
      ...
    }:
    {
      age.secrets.harmonia-signing-key.file = my.secrets.harmonia-signing-key.file;

      # Reachable over tailscale only: port 5000 is never opened publicly,
      # tailscale0 is a trusted interface.
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
          # the union of the hosts' cachePackages (modules/system/cache.nix)
          nix build --refresh --out-link /var/lib/prebuilt-cache \
            "github:maxverbeek/nixconfig#cache"
        '';
      };
    };
}
