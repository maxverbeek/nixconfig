{
  # Confluence credentials come from the keyring:
  #   secret-tool store --label='conflucloner email' service conflucloner key email
  #   secret-tool store --label='conflucloner token' service conflucloner key token
  nixos.programs.conflucloner =
    { my, ... }:
    {
      my.cachePackages.conflucloner = my.pkgs.conflucloner;
      environment.systemPackages = [ my.pkgs.conflucloner ];
    };
}
