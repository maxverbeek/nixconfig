{ pkgs, ... }:
pkgs.vimPlugins.kanagawa-nvim.overrideAttrs (old: {
  # see file in repo: $out/extras/alacritty_kanagawa.yml
  # dont know how to convert yml to nix, so i did it manually
  #
  # `colors.*` is Wave (dark). The Lotus (light) twin lives in
  # `colors.lotus.*` with identical shape, transcribed from the same
  # $out/extras/{foot,alacritty} files. Kept side by side so a light/dark
  # pair is one attrset lookup apart -- see modules/desktop/theme.nix.
  passthru.colors.foot = {
    foreground = "dcd7ba";
    background = "1f1f28";

    selection-foreground = "c8c093";
    selection-background = "2d4f67";

    regular0 = "090618";
    regular1 = "c34043";
    regular2 = "76946a";
    regular3 = "c0a36e";
    regular4 = "7e9cd8";
    regular5 = "957fb8";
    regular6 = "6a9589";
    regular7 = "c8c093";

    bright0 = "727169";
    bright1 = "e82424";
    bright2 = "98bb6c";
    bright3 = "e6c384";
    bright4 = "7fb4ca";
    bright5 = "938aa9";
    bright6 = "7aa89f";
    bright7 = "dcd7ba";

    "16" = "ffa066";
    "17" = "ff5d62";
  };

  passthru.colors.alacritty = {
    primary = {
      background = "0x1f1f28";
      foreground = "0xdcd7ba";
    };

    normal = {
      black = "0x090618";
      red = "0xc34043";
      green = "0x76946a";
      yellow = "0xc0a36e";
      blue = "0x7e9cd8";
      magenta = "0x957fb8";
      cyan = "0x6a9589";
      white = "0xc8c093";
    };

    bright = {
      black = "0x727169";
      red = "0xe82424";
      green = "0x98bb6c";
      yellow = "0xe6c384";
      blue = "0x7fb4ca";
      magenta = "0x938aa9";
      cyan = "0x7aa89f";
      white = "0xdcd7ba";
    };

    selection = {
      background = "0x2d4f67";
      foreground = "0xc8c093";
    };

    indexed_colors = [
      {
        index = 16;
        color = "0xffa066";
      }
      {
        index = 17;
        color = "0xff5d62";
      }
    ];
  };

  # some colors i've assigned random names so that they can be used elsewhere
  passthru.colors.term = {
    normal = {
      black = "#090618";
      red = "#C34043";
      green = "#76946A";
      yellow = "#C0A36E";
      blue = "#7E9CD8";
      purple = "#957FB8";
      teal = "#6A9589";
      white = "#C8C093";
    };

    bright = {
      grey = " #727169";
      red = " #E82424";
      green = "#98BB6C";
      yellow = "#E6C384";
      blue = "#7FB4CA";
      purple = "#938AA9";
      teal = "#7AA89F";
      white = "#DCD7BA";
    };

    extended = {
      orange = "#FFA066";
      red = "#FF5D62";
      black = "#1F1F28";
      slate = "#2D4F67";
      lbrown = "#C8C093";
      blue = "#72A7BC";
      darker = "#15161E";
      background = "#1f1f28";
    };
  };

  # Lotus: the light half of Kanagawa. Same shape as the Wave sets above so
  # the two can be swapped by attribute path alone.
  # From $out/extras/foot/kanagawa-lotus.ini.
  passthru.colors.lotus.foot = {
    foreground = "545464";
    background = "f2ecbc";

    selection-foreground = "dcd7ba";
    selection-background = "c9cbd1";

    regular0 = "1f1f28";
    regular1 = "c84053";
    regular2 = "6f894e";
    regular3 = "77713f";
    regular4 = "4d699b";
    regular5 = "b35b79";
    regular6 = "597b75";
    regular7 = "545464";

    bright0 = "8a8980";
    bright1 = "d7474b";
    bright2 = "6e915f";
    bright3 = "836f4a";
    bright4 = "6693bf";
    bright5 = "624c83";
    bright6 = "5e857a";
    bright7 = "43436c";

    "16" = "e98a00";
    "17" = "e82424";
  };

  # From $out/extras/alacritty/kanagawa_lotus.toml.
  passthru.colors.lotus.alacritty = {
    primary = {
      background = "0xf2ecbc";
      foreground = "0x545464";
    };

    normal = {
      black = "0x1f1f28";
      red = "0xc84053";
      green = "0x6f894e";
      yellow = "0x77713f";
      blue = "0x4d699b";
      magenta = "0xb35b79";
      cyan = "0x597b75";
      white = "0x545464";
    };

    bright = {
      black = "0x8a8980";
      red = "0xd7474b";
      green = "0x6e915f";
      yellow = "0x836f4a";
      blue = "0x6693bf";
      magenta = "0x624c83";
      cyan = "0x5e857a";
      white = "0x43436c";
    };

    selection = {
      background = "0xc9cbd1";
      foreground = "0xdcd7ba";
    };

    indexed_colors = [
      {
        index = 16;
        color = "0xe98a00";
      }
      {
        index = 17;
        color = "0xe82424";
      }
    ];
  };

  # Same random-name treatment as colors.term above, so the two are
  # interchangeable wherever `term` is consumed.
  passthru.colors.lotus.term = {
    normal = {
      black = "#1F1F28";
      red = "#C84053";
      green = "#6F894E";
      yellow = "#77713F";
      blue = "#4D699B";
      purple = "#B35B79";
      teal = "#597B75";
      white = "#545464";
    };

    bright = {
      grey = "#8A8980";
      red = "#D7474B";
      green = "#6E915F";
      yellow = "#836F4A";
      blue = "#6693BF";
      purple = "#624C83";
      teal = "#5E857A";
      white = "#43436C";
    };

    extended = {
      orange = "#E98A00";
      red = "#E82424";
      black = "#F2ECBC";
      slate = "#C9CBD1";
      lbrown = "#8A8980";
      blue = "#4E8CA2";
      darker = "#E7DBA0";
      background = "#f2ecbc";
    };
  };
})
