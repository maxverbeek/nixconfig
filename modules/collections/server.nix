{
  # The VPS.
  nixos.collections.server =
    { my, ... }:
    {
      imports = with my.modules.nixos; [
        system.vps
        services.sshd
        services.fail2ban
      ];
    };
}
