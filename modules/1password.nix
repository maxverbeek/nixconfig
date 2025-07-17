{ pkgs, ... }:
{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "max" ];
  };

  security.polkit.enable = true;

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        chromium
        zen
        .zen-wrapped
      '';
      mode = "0755";
    };
  };

  # used by some cheeky bindings to copy stuff between x and wayland
  # i hope that 1pass fixes their wayland client soon
  environment.systemPackages = [
    pkgs.xsel
  ];
}
