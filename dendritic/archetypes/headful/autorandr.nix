{ ... }:
{
  # Home-manager: autorandr monitor profiles (X11 legacy)
  flake.modules.homeManager.autorandr =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      fingerprints = {
        dell1440p = "00ffffffffffff0010acd9414c513241251e0104b53c22783b8cb5af4f43ab260e5054a54b00d100d1c0b300a94081808100714fe1c0565e00a0a0a029503020350055502100001a000000ff00374d37513032330a2020202020000000fc0044454c4c205332373231444746000000fd0030a5fafa41010a2020202020200180020337f1513f101f200514041312110302010607151623090707830100006d1a0000020b30a5000f62256230e305c000e606050162623ef4fb0050a0a028500820680055502100001a40e7006aa0a067500820980455502100001a6fc200a0a0a055503020350055502100001a000000000000000000000000000000000000ca";
        aoc1080p = "00ffffffffffff0005e3010014030000281a0104a5351e783bf6e5a7534d9924145054bfef00d1c0b30095008180814081c001010101023a801871382d40582c4500132b2100001e804180507038274008209804132b2100001e000000fd00234c535311010a202020202020000000fc003234363047350a20202020202001e102031ef14b901f051404130312021101230907078301000065030c0010008c0ad08a20e02d10103e9600132b21000018011d007251d01e206e285500132b2100001e8c0ad08a20e02d10103e9600132b210000188c0ad090204031200c405500132b210000180000000000000000000000000000000000000000000000000031";
        officesamsung = "00ffffffffffff004c2d710f563855301a1d0103805021782a46c5a5564f9b250f5054bfef80714f810081c081809500a9c0b3000101e77c70a0d0a0295030203a001d4d3100001a000000fd00324b1e7829000a202020202020000000fc005333344a3535780a2020202020000000ff0048544f4d3630313035310a20200127020324f147901f041303125a230907078301000067030c002000803c67d85dc4015280009d6770a0d0a0225030203a001d4d3100001a584d00b8a1381440f82c45001d4d3100001e565e00a0a0a02950302035001d4d3100001a023a801871382d40582c45001d4d3100001e539d70a0d0a0345030203a001d4d3100001a0060";
        laptopmain = "00ffffffffffff0009e5ff0600000000011a0104a522137802c9a0955d599429245054000000010101010101010101010101010101019c3b803671383c403020360058c21000001a000000000000000000000000000000000000000000fe00424f452043510a202020202020000000fe004e5631353646484d2d4e34390a007d";
      };
    in
    {
      programs.autorandr = {
        enable = !config.device.hyprland.enable;

        profiles."home" = {
          fingerprint."DP-2" = fingerprints.aoc1080p;
          fingerprint."DP-4" = fingerprints.dell1440p;
          config."DP-2" = {
            enable = true;
            primary = false;
            position = "2560x360";
            mode = "1920x1080";
            rate = "74.92";
          };
          config."DP-4" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2560x1440";
            rate = "143.91";
            dpi = 109;
          };
        };

        profiles."office" = {
          fingerprint."HDMI-1" = fingerprints.officesamsung;
          fingerprint."eDP-1" = fingerprints.laptopmain;
          config."eDP-1" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.03";
          };
          config."HDMI-1" = {
            enable = true;
            primary = false;
            position = "1920x0";
            mode = "3440x1440";
            rate = "49.99";
          };
        };
      };

      systemd.user.services.autorandr = lib.mkIf (!config.device.hyprland.enable) {
        Unit = {
          Description = "Autorandr to fix my displays";
          Before = [ "graphical-session.target" ];
          PartOf = [ "graphical-session-pre.target" ];
        };
        Install.WantedBy = [ "graphical-session-pre.target" ];
        Service = {
          ExecStart = "${pkgs.autorandr}/bin/autorandr -c";
          Type = "oneshot";
        };
      };
    };
}
