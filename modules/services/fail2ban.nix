{ ... }:
{
  flake.modules.nixos.fail2ban =
    { ... }:
    {
      services.fail2ban = {
        enable = true;
        bantime = "${toString (7 * 24)}h";
      };

      environment.etc."fail2ban/filter.d/caddy-status-401-403-500.conf".text = ''
        [Definition]
        failregex = ^\s*\{.*"client_ip"\s*:\s*"<HOST>".*"status"\s*:\s*(?:401|403|500).*\}$
        ignoreregex =
        datepattern = "ts":{EPOCH}
      '';
    };
}
